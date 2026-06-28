# StellChat Mobile Client

The StellChat client is a premium, cross-platform mobile application built using Flutter. It is designed dark-first, prioritizing conversation flows and visual aesthetics.

---

## Technical Stack

- **Core SDK:** Flutter (Dart)
- **State Management:** Riverpod (Reactive cache management)
- **Local Databases:** Hive (High-performance key-value) & Secure Storage
- **Cryptographic Library:** Sodium (Sodium sumo binding for curve25519, secretbox, and signing)
- **Local Scanner:** Mobile Scanner (Fast QR and barcode parsing)

---

## Cryptography & Key Management

### Identity Generation
StellChat uses BIP-39 mnemonic generation to produce 24 words. These words derive:
1. **Ed25519 Signing Keys:** Used to sign API handshakes and messages.
2. **X25519 Encryption Keys:** Used for Diffie-Hellman (ECDH) key exchanges to establish end-to-end encrypted tunnels.

### Message Encryption
Before being sent to the relay, chat messages are encrypted with the recipient's public encryption key using Libsodium's authenticated encryption `crypto_box` API:
```dart
final cipherText = sodium.crypto.box.easy(
  message: utf8.encode(plaintext),
  nonce: nonce,
  publicKey: recipientPublicKey,
  secretKey: mySecretKey,
);
```

---

## Local Storage Layout

Local data is sandboxed on the user's device:
1. **Encrypted Identity Keys:** Stored inside OS secure hardware keychain (Keystore on Android, Keychain on iOS) via `flutter_secure_storage`.
2. **Conversation Lists & Messages:** Stored inside local Hive database boxes (`messages`, `contacts`, `conversation_states`).
3. **Cache & Media:** Encrypted locally before being cached to disk.

---

## UI Components & Design System

The application uses custom design system tokens defined in `lib/design_system/`:
- **AppColors:** Curated dark theme palette. Uses deep blacks (`#0A0A0A`), sleek carbon surfaces (`#141414`), and vibrant accents (`colors.ghostAccent`).
- **GhostSurface:** Custom rounded containment blocks with custom gradients and glassmorphism.
- **GhostButton:** Micro-animated custom buttons.
- **AppTypography:** Uses custom typography layouts.
