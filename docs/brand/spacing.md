# StellChat — Spacing & Layout Grid

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
