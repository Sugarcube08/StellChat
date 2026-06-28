import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';

// ============================================================================
// 1. Dual-Ring Gradient LoadingAnimation
// ============================================================================
class LoadingAnimation extends StatefulWidget {
  final double size;
  const LoadingAnimation({super.key, this.size = 50});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Colors.transparent,
              AppColors.accent,
              AppColors.info,
              Colors.transparent,
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: colors.backgroundPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: colors.info,
              size: widget.size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. WalletConnectedAnimation (Pulse and Scaling checkmark)
// ============================================================================
class WalletConnectedAnimation extends StatefulWidget {
  const WalletConnectedAnimation({super.key});

  @override
  State<WalletConnectedAnimation> createState() => _WalletConnectedAnimationState();
}

class _WalletConnectedAnimationState extends State<WalletConnectedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outward pulse rings
            if (_controller.value > 0.5)
              Opacity(
                opacity: (1.0 - (_controller.value - 0.5) * 2).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.success, width: 2),
                    ),
                  ),
                ),
              ),
            // Core badge
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: AppColors.successGradient),
                  boxShadow: [
                    BoxShadow(
                      color: colors.success.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.wallet_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Floating Sparkle particles
            if (_controller.value > 0.4) ..._buildParticles(colors.success),
          ],
        );
      },
    );
  }

  List<Widget> _buildParticles(Color color) {
    final progress = (_controller.value - 0.4) * 1.66; // Normalized [0, 1]
    final positions = [
      const Offset(-30, -30),
      const Offset(30, -35),
      const Offset(-35, 30),
      const Offset(35, 25),
    ];
    return positions.map((offset) {
      final currentOffset = Offset(
        offset.dx * progress,
        offset.dy * progress,
      );
      return Transform.translate(
        offset: currentOffset,
        child: Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0),
          child: Icon(
            Icons.star_rounded,
            color: color,
            size: 14 * (1.0 - progress / 2),
          ),
        ),
      );
    }).toList();
  }
}

// ============================================================================
// 3. PaymentSuccessAnimation
// ============================================================================
class PaymentSuccessAnimation extends StatefulWidget {
  const PaymentSuccessAnimation({super.key});

  @override
  State<PaymentSuccessAnimation> createState() => _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _slideAnimation = Tween<double>(begin: -100.0, end: 150.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInBack)),
    );

    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Paper airplane flying up-right
              if (_controller.value < 0.5)
                Transform.translate(
                  offset: Offset(_slideAnimation.value, -_slideAnimation.value * 0.8),
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accent.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.accent,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              // Success badge appearing at center
              if (_controller.value >= 0.4)
                Transform.scale(
                  scale: _badgeScale.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: AppColors.successGradient),
                      boxShadow: [
                        BoxShadow(
                          color: colors.success.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// 4. VerificationSuccessAnimation
// ============================================================================
class VerificationSuccessAnimation extends StatefulWidget {
  const VerificationSuccessAnimation({super.key});

  @override
  State<VerificationSuccessAnimation> createState() => _VerificationSuccessAnimationState();
}

class _VerificationSuccessAnimationState extends State<VerificationSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_controller);

    _rotate = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotate.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.success.withOpacity(0.15),
                border: Border.all(color: colors.success, width: 3),
              ),
              child: Icon(
                Icons.verified_rounded,
                color: colors.success,
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 5. EmptyStateAnimation (Floating Breathing Effect)
// ============================================================================
class EmptyStateAnimation extends StatefulWidget {
  final Widget child;
  const EmptyStateAnimation({super.key, required this.child});

  @override
  State<EmptyStateAnimation> createState() => _EmptyStateAnimationState();
}

class _EmptyStateAnimationState extends State<EmptyStateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _float.value),
          child: widget.child,
        );
      },
    );
  }
}
