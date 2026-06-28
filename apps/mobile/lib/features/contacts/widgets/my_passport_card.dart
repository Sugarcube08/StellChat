import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/spacing.dart';
import '../../../design_system/colors.dart';

class MyPassportCard extends StatelessWidget {
  final String walletAddress;
  final VoidCallback onTap;

  const MyPassportCard({
    super.key,
    required this.walletAddress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return GhostCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      padding: const EdgeInsets.all(AppSpacing.l),
      type: GhostSurfaceType.elevated,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: walletAddress,
                  version: QrVersions.auto,
                  size: 80.0,
                  gapless: false,
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STELLAR WALLET PROFILE',
                      style: AppTypography.caption(context).copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.ghostAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      walletAddress,
                      style: AppTypography.section(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to show QR code',
                      style: AppTypography.caption(context).copyWith(
                        color: colors.secondaryText.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: colors.secondaryText.withAlpha(50)),
            ],
          ),
        ],
      ),
    );
  }
}
