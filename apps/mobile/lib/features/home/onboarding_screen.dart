import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/network/relay_manager.dart';
import '../../core/widgets/navigation_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _mnemonicController = TextEditingController();
  bool _isConnecting = false;
  bool _showMnemonicInput = false;

  @override
  void dispose() {
    _mnemonicController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect({String? mnemonic}) async {
    setState(() => _isConnecting = true);
    final walletService = ref.read(stellarWalletServiceProvider);

    try {
      await walletService.connectWallet(
        provider: mnemonic != null ? "mnemonic" : "embedded",
        mnemonic: mnemonic,
      );

      // Auto-connect websocket relay
      final activeRelay = await ref.read(activeRelayProvider.future);
      final relayManager = ref.read(relayManagerProvider);
      final wsService = ref.read(webSocketServiceProvider);

      if (activeRelay != null && mounted) {
        final authenticatedRelay = RelayProfile(
          id: activeRelay.id,
          label: activeRelay.label,
          websocketUrl:
              "${activeRelay.websocketUrl}?token=${walletService.sessionToken}",
          apiUrl: activeRelay.apiUrl,
          token: walletService.sessionToken,
        );
        relayManager.wakeUpRelay(authenticatedRelay);
        wsService.connect(authenticatedRelay);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavigationShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Sleek space theme background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // StellChat Brand Logo / Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/banner.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),

                // Title & Description
                const Text(
                  'StellChat',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Private conversations with native,\nverifiable Stellar payments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 48),

                if (_isConnecting) ...[
                  const CircularProgressIndicator(color: Colors.blueAccent),
                  const SizedBox(height: 24),
                  Text(
                    "Verifying wallet challenge signature...",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                ] else if (!_showMnemonicInput) ...[
                  // Primary Action Buttons
                  ElevatedButton(
                    onPressed: () => _handleConnect(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'CONNECT STELLAR WALLET',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text option for importing seed
                  TextButton(
                    onPressed: () {
                      setState(() => _showMnemonicInput = true);
                    },
                    child: Text(
                      'IMPORT MNEMONIC / SEED',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ] else ...[
                  // Custom Seed Mnemonic Entry Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ENTER SEED / MNEMONIC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _mnemonicController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Enter your 24-word seed phrase or private key...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final seed = _mnemonicController.text.trim();
                            if (seed.isNotEmpty) {
                              _handleConnect(mnemonic: seed);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('IMPORT & CONNECT'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() => _showMnemonicInput = false);
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),

                // Footer
                Text(
                  'StellChat is secure and local-first.\nYour wallet keys never leave this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
