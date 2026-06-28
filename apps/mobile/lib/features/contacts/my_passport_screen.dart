import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/providers.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../../design_system/components/components.dart';

class MyPassportScreen extends ConsumerStatefulWidget {
  const MyPassportScreen({super.key});

  @override
  ConsumerState<MyPassportScreen> createState() => _MyPassportScreenState();
}

class _MyPassportScreenState extends ConsumerState<MyPassportScreen> {
  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(stellarWalletServiceProvider);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: AppBar(
        title: const Text('STELLAR WALLET PROFILE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              children: [
                // QR Card
                StellSurface(
                  type: StellSurfaceType.elevated,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: QrImageView(
                          data: wallet.address,
                          version: QrVersions.auto,
                          size: 180,
                          gapless: false,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          wallet.address,
                          textAlign: TextAlign.center,
                          style: AppTypography.section(context).copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        'STELLCHAT WALLET ADDRESS',
                        style: AppTypography.caption(context).copyWith(
                          color: colors.stellAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Balances Section
                StellSurface(
                  type: StellSurfaceType.secondary,
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BALANCES',
                        style: AppTypography.caption(context).copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('XLM (Stellar Native)', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '${wallet.xlmBalance.toStringAsFixed(4)} XLM',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('USDC (Stablecoin)', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '${wallet.usdcBalance.toStringAsFixed(2)} USDC',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: StellButton(
                        label: 'COPY ADDRESS',
                        icon: Icons.copy,
                        type: StellButtonType.secondary,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: wallet.address));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Address copied to clipboard!')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: StellButton(
                        label: 'REFRESH',
                        icon: Icons.refresh,
                        type: StellButtonType.primary,
                        onPressed: () async {
                          await wallet.fetchBalances();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Balances updated.')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'Share this QR code with others to receive private Stellar payments directly inside StellChat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: colors.textMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
