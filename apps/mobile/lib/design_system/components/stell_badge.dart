import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';
import '../typography.dart';

class StellBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const StellBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: color ?? colors.stellAccent.withAlpha(40),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(
          color: color?.withAlpha(80) ?? colors.stellAccent.withAlpha(80),
          width: 0.5,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption(context).copyWith(
          color: textColor ?? color ?? colors.stellAccent,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontSize: 10,
        ),
      ),
    );
  }
}
