import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../spacing.dart';
import '../typography.dart';
import '../haptics.dart';
import '../animations.dart';

// ==========================================
// 1. PrimaryButton
// ==========================================
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? colors.borderPrimary : null,
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  AppHaptics.light();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.m,
              horizontal: AppSpacing.l,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.s),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                Text(
                  label,
                  style: AppTypography.body(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

// ==========================================
// 2. SecondaryButton
// ==========================================
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        color: colors.surfaceSecondary,
        border: Border.all(color: colors.borderPrimary, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  AppHaptics.light();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.m,
              horizontal: AppSpacing.l,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                      ),
                    ),
                  )
                else if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: Icon(icon, color: colors.textPrimary, size: 18),
                  ),
                Text(
                  label,
                  style: AppTypography.body(context).copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
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

// ==========================================
// 3. OutlineButton
// ==========================================
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(
          color: isDisabled ? colors.borderMuted : colors.accent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  AppHaptics.light();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.m,
              horizontal: AppSpacing.l,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                      ),
                    ),
                  )
                else if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: Icon(icon, color: colors.accent, size: 18),
                  ),
                Text(
                  label,
                  style: AppTypography.body(context).copyWith(
                    color: isDisabled ? colors.textMuted : colors.accent,
                    fontWeight: FontWeight.w600,
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

// ==========================================
// 4. WalletButton
// ==========================================
class WalletButton extends StatelessWidget {
  final String publicKey;
  final bool isConnected;
  final VoidCallback onPressed;

  const WalletButton({
    super.key,
    required this.publicKey,
    required this.isConnected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final displayKey = publicKey.length > 10
        ? '${publicKey.substring(0, 6)}...${publicKey.substring(publicKey.length - 4)}'
        : publicKey;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(
          color: isConnected ? colors.success.withOpacity(0.3) : colors.borderPrimary,
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            colors.surfaceSecondary.withOpacity(0.6),
            colors.surfacePrimary.withOpacity(0.8),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.medium();
            onPressed();
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.s + 4,
              horizontal: AppSpacing.m,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? colors.success : colors.textMuted,
                    boxShadow: [
                      if (isConnected)
                        BoxShadow(
                          color: colors.success.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  isConnected ? displayKey : "Connect Wallet",
                  style: AppTypography.secondary(context).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  isConnected ? Icons.check_circle_outline : Icons.wallet_rounded,
                  size: 16,
                  color: isConnected ? colors.success : colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. PaymentCard
// ==========================================
class PaymentCard extends StatelessWidget {
  final String cardHolder;
  final String balance;
  final String address;
  final VoidCallback? onCopyAddress;

  const PaymentCard({
    super.key,
    required this.cardHolder,
    required this.balance,
    required this.address,
    this.onCopyAddress,
  });

  @override
  Widget build(BuildContext context) {
    final shortAddress = address.length > 20
        ? '${address.substring(0, 10)}...${address.substring(address.length - 8)}'
        : address;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGradient[0].withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Stack(
          children: [
            // Decorative shapes
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "StellChat Pay",
                            style: AppTypography.body(context).copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Stellar Network",
                            style: AppTypography.caption(context).copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      // Four-point sparkle logo
                      const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BALANCE",
                        style: AppTypography.caption(context).copyWith(
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balance,
                        style: AppTypography.hero(context).copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ACCOUNT HOLDER",
                            style: AppTypography.caption(context).copyWith(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            cardHolder.toUpperCase(),
                            style: AppTypography.secondary(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: address));
                          AppHaptics.light();
                          if (onCopyAddress != null) onCopyAddress!();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                          ),
                          child: Row(
                            children: [
                              Text(
                                shortAddress,
                                style: AppTypography.caption(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.copy_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. VerificationCard
// ==========================================
class VerificationCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isVerified;
  final VoidCallback? onTap;

  const VerificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.isVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(
          color: isVerified
              ? colors.success.withOpacity(0.2)
              : colors.error.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isVerified
                        ? colors.success.withOpacity(0.1)
                        : colors.error.withOpacity(0.1),
                  ),
                  child: Icon(
                    isVerified ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
                    color: isVerified ? colors.success : colors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTypography.caption(context),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. MessageBubble
// ==========================================
class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: AppSpacing.s,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSpacing.radiusM),
            topRight: const Radius.circular(AppSpacing.radiusM),
            bottomLeft: Radius.circular(isMe ? AppSpacing.radiusM : 4),
            bottomRight: Radius.circular(isMe ? 4 : AppSpacing.radiusM),
          ),
          gradient: isMe
              ? const LinearGradient(
                  colors: AppColors.secondaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMe ? null : colors.surfaceSecondary,
          border: isMe
              ? null
              : Border.all(
                  color: colors.borderPrimary,
                  width: 1,
                ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s + 4,
          horizontal: AppSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: AppTypography.body(context).copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTypography.caption(context).copyWith(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 8. PaymentBubble
// ==========================================
class PaymentBubble extends StatelessWidget {
  final String amount;
  final String note;
  final String status; // Sent, Received, Pending
  final bool isMe;
  final String time;
  final VoidCallback? onActionPressed;

  const PaymentBubble({
    super.key,
    required this.amount,
    required this.note,
    required this.status,
    required this.isMe,
    required this.time,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bool isPending = status.toLowerCase() == 'pending';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: AppSpacing.s,
        ),
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          color: colors.surfaceSecondary,
          border: Border.all(
            color: isPending
                ? colors.warning.withOpacity(0.3)
                : colors.success.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header with Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusM - 1.5),
                  topRight: Radius.circular(AppSpacing.radiusM - 1.5),
                ),
                gradient: LinearGradient(
                  colors: isPending
                      ? [colors.warning.withOpacity(0.2), colors.warning.withOpacity(0.05)]
                      : AppColors.successGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMe ? "Sent Payment" : "Received Request",
                        style: AppTypography.caption(context).copyWith(
                          color: isPending ? colors.warning : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        isPending ? Icons.pending_actions_rounded : Icons.stars_rounded,
                        color: isPending ? colors.warning : Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    amount,
                    style: AppTypography.hero(context).copyWith(
                      color: isPending ? colors.textPrimary : Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            // Note & Status Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.isNotEmpty) ...[
                    Text(
                      note,
                      style: AppTypography.body(context),
                    ),
                    const SizedBox(height: AppSpacing.s),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPending
                              ? colors.warning.withOpacity(0.1)
                              : colors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppTypography.caption(context).copyWith(
                            color: isPending ? colors.warning : colors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: AppTypography.caption(context).copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  if (onActionPressed != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPending ? colors.accent : colors.surfacePrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                          ),
                          elevation: 0,
                        ),
                        onPressed: onActionPressed,
                        child: Text(isPending ? "Pay Request" : "Details"),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 9. InputField
// ==========================================
class InputField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const InputField({
    super.key,
    required this.hintText,
    this.controller,
    this.isObscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChanged,
      style: AppTypography.body(context),
      cursorColor: colors.accent,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.secondary(context).copyWith(color: colors.textMuted),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: colors.textSecondary, size: 20) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.m,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          borderSide: BorderSide(color: colors.borderPrimary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
      ),
    );
  }
}

// ==========================================
// 10. SearchBar
// ==========================================
class SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchBar({
    super.key,
    this.hint = "Search...",
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderPrimary, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: colors.accent,
              style: AppTypography.body(context),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.body(context).copyWith(color: colors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 11. BrandChip
// ==========================================
class BrandChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BrandChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s,
          horizontal: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isSelected
              ? const LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: isSelected ? null : colors.surfaceSecondary,
          border: Border.all(
            color: isSelected ? Colors.transparent : colors.borderPrimary,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption(context).copyWith(
            color: isSelected ? Colors.white : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 12. BrandDialog
// ==========================================
class BrandDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget? actions;

  const BrandDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    Widget? actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: AppAnimations.medium,
      pageBuilder: (context, anim1, anim2) => BrandDialog(
        title: title,
        content: content,
        actions: actions,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return AppAnimations.scale(
          duration: AppAnimations.medium,
          begin: 0.9,
          end: 1.0,
          child: AppAnimations.fade(
            duration: AppAnimations.medium,
            begin: 0,
            end: 1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AlertDialog(
        backgroundColor: colors.surfacePrimary.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          side: BorderSide(color: colors.borderPrimary, width: 1.5),
        ),
        title: Text(
          title,
          style: AppTypography.title(context).copyWith(fontSize: 22),
        ),
        content: Text(
          content,
          style: AppTypography.body(context).copyWith(color: colors.textSecondary),
        ),
        actions: [
          actions ??
              PrimaryButton(
                label: "Dismiss",
                onPressed: () => Navigator.pop(context),
              )
        ],
      ),
    );
  }
}

// ==========================================
// 13. BrandBottomSheet
// ==========================================
class BrandBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const BrandBottomSheet({
    super.key,
    required this.title,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => BrandBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusL),
          topRight: Radius.circular(AppSpacing.radiusL),
        ),
        border: Border(
          top: BorderSide(color: colors.borderPrimary, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.s,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        left: AppSpacing.l,
        right: AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.header(context).copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.transparent, height: AppSpacing.s),
          child,
        ],
      ),
    );
  }
}

// ==========================================
// 14. BrandNavigationBar
// ==========================================
class BrandNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;

  const BrandNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderPrimary, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) {
          AppHaptics.light();
          onTap(idx);
        },
        backgroundColor: colors.backgroundSecondary,
        indicatorColor: colors.accent.withOpacity(0.12),
        destinations: destinations,
      ),
    );
  }
}

// ==========================================
// 15. BrandTopBar
// ==========================================
class BrandTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const BrandTopBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppBar(
      backgroundColor: colors.backgroundPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: leading ??
          (Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
                  onPressed: () {
                    AppHaptics.light();
                    Navigator.pop(context);
                  },
                )
              : null),
      title: Text(
        title,
        style: AppTypography.header(context).copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: colors.borderPrimary,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ==========================================
// 16. BrandFloatingActionButton
// ==========================================
class BrandFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const BrandFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGradient[0].withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.medium();
            onPressed();
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 17. BrandAvatar
// ==========================================
class BrandAvatar extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final double size;
  final bool isVerified;

  const BrandAvatar({
    super.key,
    this.imageUrl,
    required this.label,
    this.size = 48,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final String initial = label.isNotEmpty ? label[0].toUpperCase() : '';

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.borderPrimary, width: 1.5),
            gradient: const LinearGradient(
              colors: AppColors.secondaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _fallbackLetter(context, initial),
                  )
                : _fallbackLetter(context, initial),
          ),
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colors.backgroundPrimary,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D68F), // Success verification green
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackLetter(BuildContext context, String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ==========================================
// 18. BrandLoadingIndicator
// ==========================================
class BrandLoadingIndicator extends StatefulWidget {
  final double size;

  const BrandLoadingIndicator({
    super.key,
    this.size = 40,
  });

  @override
  State<BrandLoadingIndicator> createState() => _BrandLoadingIndicatorState();
}

class _BrandLoadingIndicatorState extends State<BrandLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 0.8,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              backgroundColor: Colors.transparent,
            ),
            // Stellar four-point sparkle in center
            Icon(
              Icons.star_rounded,
              color: colors.info,
              size: widget.size * 0.45,
            ),
          ],
        ),
      ),
    );
  }
}
