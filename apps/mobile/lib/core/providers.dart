import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodium/sodium_sumo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'network/relay_manager.dart';
import 'network/websocket_service.dart';
import 'notification_service.dart';

import '../features/chat/message.dart';

import '../features/chat/symmetric_chat_service.dart';
import '../features/contacts/contact_service.dart';
import '../features/contacts/contact_resolver.dart';
import '../features/chat/dm_service.dart';
import '../features/chat/chat_repository.dart';
import '../features/chat/conversation_service.dart';
import '../features/media/media_service.dart';
import '../features/media/media_manager.dart';
import '../features/media/share_service.dart';
import 'package:flutter/foundation.dart';
import 'stellar/stellar_wallet_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sodiumProvider = Provider<SodiumSumo>((ref) => throw UnimplementedError());

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // On some devices, the key might be lost if we don't use this
      resetOnError: true,
    ),
  );
});

class IdentityServiceWrapper {
  final SodiumSumo sodium;
  final dynamic walletIdentity;
  final String address;
  
  IdentityServiceWrapper(this.sodium, this.walletIdentity, this.address);
  
  dynamic get currentIdentity => walletIdentity;
  bool get hasIdentity => walletIdentity != null;
  
  String derivePublicId(Uint8List ed25519PubKey) {
    return address;
  }
}

final identityServiceProvider = Provider<dynamic>((ref) {
  final wallet = ref.watch(stellarWalletServiceProvider);
  return IdentityServiceWrapper(wallet.sodium, wallet.walletIdentity, wallet.address);
});

final dmServiceProvider = Provider<DMService>((ref) {
  final sodium = ref.watch(sodiumProvider);
  return DMService(sodium);
});

final contactServiceProvider = Provider<ContactService>((ref) {
  final service = ContactService(ref.watch(secureStorageProvider));
  service.init();
  return service;
});

final contactResolverProvider = Provider<ContactResolver>((ref) {
  return ContactResolver(ref.watch(contactServiceProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = ChatRepository.lazy(ref);
  repo.init();
  return repo;
});

final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService(
    ref.watch(chatRepositoryProvider),
    ref.watch(contactResolverProvider),
    ref.watch(contactServiceProvider),
    ref.watch(identityServiceProvider),
    ref.watch(mediaServiceProvider),
  );
});

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService(
    ref.watch(sodiumProvider),
    ref.watch(identityServiceProvider),
  );
});

final mediaManagerProvider = Provider<MediaManager>((ref) {
  final manager = MediaManager(
    ref.watch(sodiumProvider),
    ref.watch(mediaServiceProvider),
  );
  manager.init();
  return manager;
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService(
    ref.watch(mediaManagerProvider),
  );
});

// Alias for V1 backward compatibility
final cryptoServiceProvider = identityServiceProvider;

final symmetricChatServiceProvider = Provider<SymmetricChatService>((ref) {
  final sodium = ref.watch(sodiumProvider);
  return SymmetricChatService(sodium);
});

final relayManagerProvider = Provider<RelayManager>((ref) {
  return RelayManager(ref.watch(secureStorageProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.init();
  return service;
});

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(ref);
});

final activeRelayProvider = FutureProvider<RelayProfile?>((ref) async {
  final manager = ref.watch(relayManagerProvider);
  final relays = await manager.getRelays();
  final activeId = await manager.getActiveRelayId();
  if (activeId == null && relays.isNotEmpty) {
    return relays.first;
  }
  return relays.where((r) => r.id == activeId).firstOrNull ?? (relays.isNotEmpty ? relays.first : null);
});

final recentRoomsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(relayManagerProvider).getRecentRooms();
});

final requestCountProvider = Provider<int>((ref) {
  // Watch messages box for changes
  ref.watch(messageBoxListenableProvider);
  return ref.read(conversationServiceProvider).getRequests().length;
});

final messageBoxListenableProvider = Provider<void>((ref) {
  final box = Hive.box<Message>('messages');
  void listener() => ref.invalidateSelf();
  box.listenable().addListener(listener);
  ref.onDispose(() => box.listenable().removeListener(listener));
});

final stellarWalletServiceProvider = ChangeNotifierProvider<StellarWalletService>((ref) {
  final isAndroid = defaultTargetPlatform == TargetPlatform.android && !kIsWeb;
  final host = isAndroid ? "10.0.2.2" : "localhost";
  
  final service = StellarWalletService(
    horizonUrl: "http://$host:8000",
    friendbotUrl: "http://$host:8000/friendbot",
    sodium: ref.watch(sodiumProvider),
    storage: ref.watch(secureStorageProvider),
  );
  
  // Restore previous session automatically
  service.tryRestoreSession();
  
  return service;
});
