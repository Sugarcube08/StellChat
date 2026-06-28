import os

def generate_docs():
    docs_path = "/home/sugarcube/Desktop/Documents/Code-Server/Hackathon Projects/Stellar-DH/StellChat/docs/brand"
    os.makedirs(docs_path, exist_ok=True)

    # 1. brand-guidelines.md
    with open(os.path.join(docs_path, "brand-guidelines.md"), "w") as f:
        f.write('''# StellChat — Brand Guidelines

Welcome to the StellChat Brand Guidelines. This document serves as the primary visual and behavioral source of truth for the StellChat application.

## 1. Brand Core & Personality
StellChat is a private, secure, and fast messaging application integrated with global Stellar-powered payments. Our personality is:
- **Private:** Privacy is a fundamental human right. Conversations are end-to-end encrypted, and identities are secure.
- **Premium:** Sleek, modern aesthetics that feel like Linear, Stripe, or Telegram. Focus on glassmorphism, clean borders, and responsive micro-animations.
- **Modern & Fast:** Quick page loads, responsive taps, and immediate payment clearing.
- **Minimal:** Remove clutter. Highlight content and payments without unnecessary elements or web3 clichés.
- **Trustworthy:** Transparent, native, and robust.

---

## 2. Visual Principles
- **Dark-First:** The application defaults to a deeply immersive dark mode background (`#090B12`) with highly readable text.
- **Vector-First:** All visual assets are vector assets (SVGs and VectorDrawables) for infinitely scalable visual clarity.
- **Material 3 Compliant:** Fully compatible with Material Design 3 guidelines for input fields, navigation, chips, buttons, and layouts.
- **Accessible:** Contrast ratios conform to WCAG AA standards. Sizing targets are at least 48x48dp.
''')

    # 2. logo-usage.md
    with open(os.path.join(docs_path, "logo-usage.md"), "w") as f:
        f.write('''# StellChat — Logo & Wordmark Usage

The StellChat logo represents **Conversation**, **Trust**, **Verification**, and the **Stellar Network**.

## 1. Logo Construction
- **Chat Bubble Silhouette:** Smooth curves, continuous stroke width (24px on 512x512 canvas).
- **Upward Tail:** An elegant bottom-right sweep representing positive momentum.
- **Central Sparkle:** A white 4-point stellar starburst symbol representing crypto-verification and payments.
- **Secondary Sparkle:** A smaller companion star in the upper-right corner adding asymmetry and depth.
- **Gradient Stroke:** Highlight Blue (`#35B7FF`) transitioning to Secondary Accent (`#8D6BFF`).

---

## 2. Logo Variations
All logo files are located in `assets/branding/`:
- `logo.svg` — main horizontal logo with text.
- `logo-dark.svg` — logo on dark background (`#090B12`).
- `logo-light.svg` — logo on white background.
- `logo-outline.svg` — monochrome outline.
- `logo-monochrome.svg` — monochrome white block logo.
- `icon.svg` — standalone icon.
- `icon-round.svg` / `icon-square.svg` — icons wrapped in shapes.

---

## 3. Logo Do's and Don'ts
- **DO** use the correct color gradients (`#35B7FF` to `#8D6BFF`) for the outer stroke.
- **DO** ensure the stars remain flat white (`#FFFFFF`) on dark themes.
- **DON'T** stretch or skew the logo geometry.
- **DON'T** add drop shadows or bitmap effects. Keep it flat-vector.
''')

    # 3. colors.md
    with open(os.path.join(docs_path, "colors.md"), "w") as f:
        f.write('''# StellChat — Color System

Our color palette is curated to offer high contrast, premium depth, and semantic clarity.

## 1. Primary Colors
- **Primary Background:** `#090B12` (Deep, immersive space black)
- **Surface Primary:** `#10131C` (Dark surface cards and bars)
- **Surface Secondary (Card):** `#151A24` (Slightly lighter surface for elevation)
- **Border:** `rgba(255, 255, 255, 0.06)` (Thin, crisp dividing borders)

---

## 2. Brand Accents
- **Primary Accent:** `#6C4DFF` (Vibrant purple for primary buttons)
- **Secondary Accent:** `#8D6BFF` (Highlight endpoint for gradients)
- **Highlight Blue:** `#35B7FF` (Info/Stellar blue)

---

## 3. Semantic Colors
- **Success:** `#00D68F` (Payment sent, verification success)
- **Warning:** `#F5A524` (Pending request, system alert)
- **Danger:** `#FF5C7A` (Payment failed, error state)

---

## 4. Typography Colors
- **Primary Text:** `#FFFFFF`
- **Secondary Text:** `#AEB7C6`
- **Muted Text:** `#70798B`
''')

    # 4. typography.md
    with open(os.path.join(docs_path, "typography.md"), "w") as f:
        f.write('''# StellChat — Typography

StellChat uses **Poppins** as its primary typeface to project a modern, clean, and friendly aesthetic, falling back to **Inter** or standard system sans-serif.

## 1. Typography Scale (Material 3)

| Type Style | Font Size | Font Weight | Letter Spacing |
|---|---|---|---|
| **Display / Hero** | `32pt` | Bold (700) | `0` |
| **Headline / Title** | `28pt` | SemiBold (600) | `0` |
| **Header** | `22pt` | Medium (500) | `0` |
| **Section Title** | `18pt` | Medium (500) | `0` |
| **Body Text** | `16pt` | Regular (400) | `0` |
| **Secondary Text** | `14pt` | Regular (400) | `0` |
| **Caption / Label** | `12pt` | Regular (400) | `0.5px` |

---

## 2. Wordmark Specification
The wordmark "StellChat" is typographically aligned with:
- **Font:** Poppins SemiBold.
- **Kerning/Spacing:** Generous, letter-spacing set to `0.02em` or 0 for optical alignment.
- **Color:** White (`#FFFFFF`).
''')

    # 5. iconography.md
    with open(os.path.join(docs_path, "iconography.md"), "w") as f:
        f.write('''# StellChat — Iconography & Illustrations

All visual assets inside StellChat are lightweight, vector-first, and highly optimized.

## 1. UI Icon Set (30 Icons)
Our custom outline icon set is stored in `assets/icons/`:
- **Viewport:** `24x24dp`
- **Stroke Width:** `2px`
- **Caps & Joins:** Rounded (`stroke-linecap="round"` / `stroke-linejoin="round"`)
- **Fill:** `none`
- **Stroke Color:** `currentColor` (fully dynamic)

### Available Icons:
- `chats`, `groups`, `wallet`, `payments`, `request`, `verified`, `shield`, `security`, `settings`, `camera`, `gallery`, `attachment`, `voice`, `video`, `location`, `profile`, `notification`, `privacy`, `send`, `back`, `search`, `menu`, `more`, `archive`, `delete`, `edit`, `download`, `upload`, `lock`, `unlock`.

---

## 2. Illustrations (15 Illustrations)
Lightweight SVGs located in `assets/illustrations/`:
- Flat design style using the StellChat brand gradients.
- NO 3D, stock illustrations, or heavy bitmaps.
''')

    # 6. components.md
    with open(os.path.join(docs_path, "components.md"), "w") as f:
        f.write('''# StellChat — Component Library

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
''')

    # 7. motion.md
    with open(os.path.join(docs_path, "motion.md"), "w") as f:
        f.write('''# StellChat — Motion System

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
''')

    # 8. spacing.md
    with open(os.path.join(docs_path, "spacing.md"), "w") as f:
        f.write('''# StellChat — Spacing & Layout Grid

Consistent vertical and horizontal alignment is maintained using centralized spacing tokens.

## 1. Spacing Scale
Spacing tokens are defined in `lib/design_system/spacing.dart`:

| Token | Size | Application |
|---|---|---|
| **XS** | `4.0` | Dense inline padding, icons padding |
| **S** | `8.0` | Text-to-text gap, list item gaps |
| **M** | `16.0` | Default screen margins, card padding |
| **L** | `24.0` | Large vertical dividers, section gaps |
| **XL** | `32.0` | Hero layout gaps, bottom sheet bottom margin |
| **XXL** | `48.0` | Splash screen padding, large header spacers |

---

## 2. Border Radius
- **RadiusS (`8.0`):** Small elements (Chips, notifications, text fields)
- **RadiusM (`16.0`):** Medium surfaces (Buttons, dialogs, chat bubbles)
- **RadiusL (`24.0`):** Large surfaces (Payment cards, bottom sheets)
''')

    print("Created 8 brand documentation files under docs/brand/!")

if __name__ == "__main__":
    generate_docs()
