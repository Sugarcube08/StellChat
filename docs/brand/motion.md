# StellChat — Motion System

StellChat utilizes smooth, responsive motion to elevate user experiences. All transitions run at a native 60fps.

## 1. Animation Tokens (Duration)
- **Fast:** `150ms` (taps, ripples, hovers)
- **Medium:** `250ms` (dialog transitions, page slides)
- **Slow:** `350ms` (hero animations, onboarding screens)

---

## 2. Curves
- **Standard:** `Curves.easeInOutCubic` (smooth general motion)
- **Accelerate:** `Curves.easeInCubic` (elements exiting screen)
- **Decelerate:** `Curves.easeOutCubic` (elements entering screen)
- **Emphasized:** `Curves.easeInOutQuart` (interactive hero elements)

---

## 3. Brand Motion Widgets (`brand_motion.dart`)
- `LoadingAnimation` — rotating gradient sweep around the Stellar sparkle.
- `WalletConnectedAnimation` — outward green pulse rings with popping stars.
- `PaymentSuccessAnimation` — send plane swoosh morphing into a green checkmark.
- `VerificationSuccessAnimation` — spring scale rotation of a verified badge.
- `EmptyStateAnimation` — gentle vertical floating motion.
