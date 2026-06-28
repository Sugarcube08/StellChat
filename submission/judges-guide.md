# StellChat — Judges' Evaluation Guide

StellChat is a secure, privacy-focused ephemeral messaging application integrated with native Stellar payments and Soroban zero-knowledge proof verification.

## How to Run the Project locally
1. **Clone & Setup:**
   ```bash
   git clone https://github.com/StellChat/StellChat.git
   cd StellChat
   ```
2. **Boot the Lab Stack:**
   ```bash
   # One-command reset and initialization
   make reset-demo
   ```
3. **Launch the Client:**
   Open the mobile project inside `apps/mobile` and build for Linux, Android, or macOS.

## Code Landmarks for Judges
- **Smart Contracts:** Deployed at `contracts/stellar/src/lib.rs`.
- **Zero-Knowledge Circuit:** Defined at `zk/circuits/payment_hasher.circom`.
- **Prover Service:** Written inside `apps/prover/index.js`.
- **Stellar Transaction Builder:** Located inside `apps/mobile/lib/core/stellar/stellar_wallet_service.dart`.
