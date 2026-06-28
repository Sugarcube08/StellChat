import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sodium/sodium_sumo.dart';
import 'core/theme/stell_theme.dart';
import 'core/providers.dart';
import 'design_system/colors.dart';
import 'design_system/spacing.dart';
import 'design_system/typography.dart';

import 'core/widgets/navigation_shell.dart';
import 'features/home/onboarding_screen.dart';
import 'core/app_initializer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:app_links/app_links.dart';
import 'dart:convert';
import 'core/stellar/stellar_wallet_service.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellar;
import 'features/contacts/contact_actions.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/contacts/contact.dart';
import 'features/chat/message.dart';
import 'features/chat/conversation_state.dart';
import 'core/network/relay_manager.dart';
import 'core/storage/storage_directory_helper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
class BackgroundRelayManager extends RelayManager {
  final RelayProfile _cachedRelay;
  BackgroundRelayManager(super.storage, this._cachedRelay);

  @override
  Future<RelayProfile?> getActiveRelay() async {
    return _cachedRelay;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['event'] != 'sync_required') {
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();

  // STEP 1: Firebase Initialization
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // ignore: avoid_print
  }

  // STEP 2 & 3: Identity & DB Loading from Background Cache
  // ignore: avoid_print
  
  late final Uint8List encryptionKey;
  late final RelayProfile relay;
  late final BackgroundRelayManager relayManager;
  late final SodiumSumo sodium;
  String? walletAddress;
  WalletIdentity? walletId;

  try {
    final cacheFile = await StorageDirectoryHelper.getBackgroundCacheFile();
    if (!await cacheFile.exists()) {
      // ignore: avoid_print
      return;
    }

    final cacheContent = await cacheFile.readAsString();
    final cacheData = jsonDecode(cacheContent);
    final String? hiveKeyBase64 = cacheData['hive_encryption_key'];
    if (hiveKeyBase64 == null) {
      // ignore: avoid_print
      return;
    }
    encryptionKey = base64.decode(hiveKeyBase64);

    relay = RelayProfile(
      id: cacheData['active_relay_id'] ?? 'default',
      label: cacheData['active_relay_label'] ?? 'Default Relay',
      websocketUrl: cacheData['active_relay_websocket_url'] ?? '',
      apiUrl: cacheData['active_relay_api_url'] ?? '',
      token: cacheData['active_relay_token'],
    );

    sodium = await SodiumSumoInit.init();
    await StorageDirectoryHelper.migrateIfNeeded();
    final hiveDir = await StorageDirectoryHelper.getHiveDirectory();
    Hive.init(hiveDir.path);

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ContactAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MessageAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(MessageTypeAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ConversationModeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ConversationStateAdapter());

    // Open Hive boxes
    await Future.wait([
      Hive.openBox<Message>('messages'),
      Hive.openBox<ConversationState>('conversation_states'),
      Hive.openBox('sync_metadata'),
      Hive.openBox('processed_envelopes'),
      Hive.openBox<Contact>('contacts', encryptionCipher: HiveAesCipher(encryptionKey)),
      Hive.openBox<String>('blocked_identities'),
      Hive.openBox<Map>('offline_send_queue'),
      Hive.openBox<bool>('pending_deletions'),
      Hive.openBox<Uint8List>('thumbnail_cache'),
      Hive.openBox<dynamic>('media_cache_index'),
    ]);

    final fcmMessageId = message.data['message_id'];
    final syncBox = Hive.box('sync_metadata');
    if (fcmMessageId != null) {
      await syncBox.put('notified_$fcmMessageId', true);
    }

    final storage = const FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: true));
    walletAddress = await storage.read(key: 'wallet_address');
    final sessionToken = await storage.read(key: 'session_token');
    final seedB64 = await storage.read(key: 'wallet_seed_b64');
    if (walletAddress == null || sessionToken == null || seedB64 == null) {
      return;
    }

    final seedBytes = base64Decode(seedB64);
    final stellar.KeyPair kp = stellar.KeyPair.fromSecretSeedList(seedBytes);
    final ed25519Seed = SecureKey.fromList(sodium, kp.privateKey!);
    final ed25519KeyPair = sodium.crypto.sign.seedKeyPair(ed25519Seed);
    
    final x25519Pk = sodium.crypto.sign.pkToCurve25519(ed25519KeyPair.publicKey);
    final x25519Sk = sodium.crypto.sign.skToCurve25519(ed25519KeyPair.secretKey);
    final x25519KeyPair = KeyPair(publicKey: x25519Pk, secretKey: x25519Sk);
    
    walletId = WalletIdentity(
      publicId: walletAddress,
      ed25519KeyPair: ed25519KeyPair,
      x25519KeyPair: x25519KeyPair,
    );

    relayManager = BackgroundRelayManager(storage, relay);
  } catch (e) {
    return;
  }

  final tempContainer = ProviderContainer(
    overrides: [
      sodiumProvider.overrideWithValue(sodium),
      secureStorageProvider.overrideWithValue(const FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: true))),
      identityServiceProvider.overrideWithValue(IdentityServiceWrapper(sodium, walletId, walletAddress)),
      relayManagerProvider.overrideWithValue(relayManager),
    ],
  );

  // Initialize notification service for the background isolate
  final notifService = tempContainer.read(notificationServiceProvider);
  await notifService.init();

  final chatRepo = tempContainer.read(chatRepositoryProvider);
  await chatRepo.init();

  final wsService = tempContainer.read(webSocketServiceProvider);
  final completer = Completer<void>();
  bool syncSucceeded = false;

  // STEP 4: WebSocket Sync Start
  try {
    wsService.onInboxMessages((messages) async {
      if (messages.isNotEmpty) {
        await chatRepo.processEnvelopes(messages, enableNotification: false);
      }
      syncSucceeded = true;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // Connect & Wait for challenge and identity verification
    await relayManager.wakeUpRelay(relay);
    wsService.connect(relay);

    // Complete after 5 seconds timeout as safety
    Future.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;
  } catch (_) {
  }

  // STEP 6: Direct HTTP Delivery Receipt Fallback if WebSocket sync failed or timed out
  try {
    final fcmMessageId = message.data['message_id'];
    if (fcmMessageId != null) {
      if (!syncSucceeded) {
        await chatRepo.sendDeliveryReceipt(fcmMessageId);
      }
    }
  } catch (_) {
  }

  try {
    // Grace period: Wait 1.5 seconds to ensure all outgoing TCP packets (such as message ACKs)
    // are fully flushed to the relay server before we close the socket connection.
    await Future.delayed(const Duration(milliseconds: 1500));

    wsService.disconnect();
    tempContainer.dispose();
  } catch (_) {
  }
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      } catch (_) {
        // Ignore
      }
    }
    
    // Memory discipline: limit image cache size to prevent unbounded RAM growth
    PaintingBinding.instance.imageCache.maximumSize = 20;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 10 * 1024 * 1024; // 10MB
    
    // Global Error Handlers
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      return true; // Error handled
    };

    final sodium = await SodiumSumoInit.init();
    await StorageDirectoryHelper.migrateIfNeeded();
    final hiveDir = await StorageDirectoryHelper.getHiveDirectory();
    Hive.init(hiveDir.path);
    
    late final ProviderContainer container;
    container = ProviderContainer(
      overrides: [
        sodiumProvider.overrideWithValue(sodium),
        appInitializerProvider.overrideWith((ref) => AppInitializer(container)),
      ],
    );

    // Initial kick-off (non-blocking here, SplashScreen handles wait)
    unawaited(container.read(appInitializerProvider).initialize());

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const GhostApp(),
      ),
    );
  }, (error, stack) {
    // Ignore
  });
}

class GhostApp extends ConsumerStatefulWidget {
  const GhostApp({super.key});

  @override
  ConsumerState<GhostApp> createState() => _GhostAppState();
}

class _GhostAppState extends ConsumerState<GhostApp> with WidgetsBindingObserver, ContactActions {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
    
    // Check for initial link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'stellchat' && uri.host == 'identity') {
      final payload = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (payload != null) {
        // Find the current navigator state and show a preview dialog
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          Future.microtask(() {
            if (context.mounted) _showDeepLinkPreview(context, payload);
          });
        }
      }
    }
  }

  void _showDeepLinkPreview(BuildContext context, String payload) {
    // Deprecated in favor of wallet address links
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    // Clear image cache on memory pressure
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'StellChat',
      theme: StellTheme.lightTheme,
      darkTheme: StellTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        
        // Add a global error widget
        ErrorWidget.builder = (details) => Builder(
          builder: (context) {
            final colors = AppColors.of(context);
            return Scaffold(
              backgroundColor: colors.backgroundPrimary,
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colors.error, size: 64),
                      const SizedBox(height: 24),
                      Text('CRITICAL UI ERROR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.textPrimary)),
                      const SizedBox(height: 16),
                      Text(details.exception.toString(), textAlign: TextAlign.center, style: TextStyle(color: colors.error, fontSize: 12, fontFamily: 'monospace')),
                      if (!kReleaseMode) ...[
                        const SizedBox(height: 16),
                        Text(details.stack.toString(), style: TextStyle(color: colors.textMuted, fontSize: 8, fontFamily: 'monospace')),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceSecondary,
                          foregroundColor: colors.textPrimary,
                        ),
                        onPressed: () {},
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );

        return child;
      },
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Star> _stars = [];
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _generateStars();
    _animateLogo();
    _checkInitialization();
  }

  void _generateStars() {
    final random = math.Random(12345);
    for (int i = 0; i < 50; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 1.5 + 0.5,
        opacity: random.nextDouble() * 0.4 + 0.1,
        speed: random.nextDouble() * 0.03 + 0.01,
      ));
    }
  }

  void _animateLogo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _logoOpacity = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialization() async {
    final initializer = ref.read(appInitializerProvider);
    while (initializer.status == InitializationStatus.initializing || 
           initializer.status == InitializationStatus.idle) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;

    if (initializer.status == InitializationStatus.failure) {
      _showInitializationError(initializer.errorMessage ?? 'Fatal initialization failure.');
      return;
    }

    final wallet = ref.read(stellarWalletServiceProvider);
    if (!wallet.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      });
      return;
    }

    _proceedToApp();
  }

  void _showInitializationError(String message) {
    final colors = AppColors.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: colors.backgroundSecondary,
          title: const Text('STARTUP FAILURE'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('StellChat could not initialize core database storage.', style: TextStyle(color: colors.textSecondary)),
              const SizedBox(height: 16),
              Text(message, style: TextStyle(color: colors.error, fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(appInitializerProvider).status = InitializationStatus.idle;
                ref.read(appInitializerProvider).initialize();
                _checkInitialization();
              },
              child: Text('RETRY', style: TextStyle(color: colors.textPrimary)),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _proceedToApp() async {
    try {
      final wallet = ref.read(stellarWalletServiceProvider);
      if (!wallet.isConnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        });
        return;
      }

      final activeRelayFuture = ref.read(activeRelayProvider.future);
      final relayManager = ref.read(relayManagerProvider);
      final wsService = ref.read(webSocketServiceProvider);

      final relay = await activeRelayFuture;
      if (mounted && relay != null) {
        final authenticatedRelay = RelayProfile(
          id: relay.id,
          label: relay.label,
          websocketUrl: "${relay.websocketUrl}?token=${wallet.sessionToken}",
          apiUrl: relay.apiUrl,
          token: wallet.sessionToken,
        );
        relayManager.wakeUpRelay(authenticatedRelay);
        wsService.connect(authenticatedRelay);
      }

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NavigationShell()),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        _showInitializationError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        children: [
          // Animated Star Field
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarFieldPainter(_stars, _starController.value),
                size: Size.infinite,
              );
            },
          ),
          // Content
          Center(
            child: AnimatedOpacity(
              opacity: _logoOpacity,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Centered logo icon
                  SvgPicture.asset(
                    'assets/branding/icon.svg',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Wordmark underneath
                  SvgPicture.asset(
                    'assets/branding/wordmark.svg',
                    height: 48,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Tagline
                  Text(
                    'Private Messaging with Stellar Payments',
                    style: AppTypography.secondary(context).copyWith(
                      color: colors.textSecondary.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Footer
                  Text(
                    'POWERED BY STELLAR',
                    style: AppTypography.caption(context).copyWith(
                      color: colors.textMuted.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarFieldPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final star in stars) {
      double y = (star.y * size.height - (animationValue * star.speed * size.height)) % size.height;
      if (y < 0) y += size.height;
      
      double opacity = star.opacity;
      if (y < 100) {
        opacity *= (y / 100);
      } else if (y > size.height - 100) {
        opacity *= ((size.height - y) / 100);
      }
      
      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(star.x * size.width, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) => true;
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}
