import 'package:flutter/material.dart';
import '../spacing.dart';
import 'stell_surface.dart';

class StellCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final StellSurfaceType type;
  final BorderRadius? borderRadius;

  const StellCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.type = StellSurfaceType.secondary,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = StellSurface(
      type: type,
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.m),
      borderRadius: borderRadius,
      child: child,
    );

    if (onTap != null) {
      current = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: current,
      );
    }

    if (margin != null) {
      current = Padding(
        padding: margin!,
        child: current,
      );
    }

    return current;
  }
}
