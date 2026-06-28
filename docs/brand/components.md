# StellChat — Component Library

Our reusable Flutter components are defined in [brand_components.dart](file:///home/sugarcube/Desktop/Documents/Code-Server/Hackathon%20Projects/Stellar-DH/StellChat/apps/mobile/lib/design_system/components/brand_components.dart).

## 1. Buttons
- **PrimaryButton:** Uses the Primary Gradient (`#5B3DF5` to `#7C5CFF`) with a rounded backplate and active press haptics. Supports loading indicators.
- **SecondaryButton:** Surface-colored (`#151A24`) with thin borders. Used for secondary actions.
- **OutlineButton:** Border-only purple button (`#6C4DFF`) for neutral actions.
- **WalletButton:** Stellar specific button showing connection status (green/grey pulse) and public key.

---

## 2. Cards & Bubbles
- **PaymentCard:** Glassmorphic card displaying Stellar balance, wallet address, and branding.
- **VerificationCard:** Dynamic card showing positive/negative verification states.
- **MessageBubble:** Asymmetric speech bubble. Sender is styled with Secondary Gradient; receiver is styled in Surface Secondary.
- **PaymentBubble:** Specialty bubble containing request/send data, metadata, status labels, and actions.

---

## 3. Navigation & Feedback
- **InputField / SearchBar:** Glassmorphic fields with active accent states.
- **BrandChip:** Rounded pill for categorization.
- **BrandDialog / BrandBottomSheet:** Backdrop blurred screens.
- **BrandAvatar:** Profiles with verified badges.
- **BrandLoadingIndicator:** Stellar sparkle spinner.
