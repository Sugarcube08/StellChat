# Stellar Network Integration

StellChat integrates native Stellar payments directly within the E2EE messaging experience. Trust-sensitive operations like verification, payment authorization, and settlement acknowledgment are performed on-chain via Stellar Soroban smart contracts, while chat histories and message persistence remain entirely off-chain to maintain privacy and performance.

---

## Supported Assets

StellChat supports two primary Stellar assets:
1. **Lumen (XLM):** Used for base transaction fees and fast direct peer-to-peer transfers.
2. **USDC (Stellar-native):** Recommended for stable value transfers, merchant requests, and zero-knowledge invoice settlements.

---

## Smart Contract Design

The `StellChatVerifier` Soroban contract manages trust operations on the Stellar network.

### Rust Contract Methods (`contracts/stellar/src/lib.rs`)

1. **`initialize(env: Env, admin: Address)`**
   - Configures the contract instance's administrator.
2. **`authorize_payment(env: Env, payment_id: u64, sender: Address, receiver: Address, amount: i128, proof_hash: BytesN<32>)`**
   - Called by the sender's wallet to authorize and record a pending payment with a target ZK hash commitment.
   - Enforces `require_auth()` verification.
3. **`verify_and_settle(env: Env, payment_id: u64, zk_proof: Bytes) -> bool`**
   - Accepts a ZK proof payload, verifies the proof matches the authorized `proof_hash`, settles the invoice status to `settled`, and publishes a `settled` Stellar event.
4. **`is_proof_verified(env: Env, proof_hash: BytesN<32>) -> bool`**
   - Read-only helper to inspect if a payment ZK proof has already been processed on-chain.

---

## Transaction Lifecycle

```
[Payee] Request Payment 
   │
   ▼ (Sends real-time PAYMENT_REQUEST message card)
[Payer] Click "Approve & Pay"
   │
   ▼ (Connects to wallet, e.g., Freighter / Albedo)
Submit transaction to Stellar Testnet (XLM / USDC transfer)
   │
   ▼ (Ledger transaction completes; yields transaction hash)
Generate Local ZK Proof (Poseidon Hash of secret + tx details)
   │
   ▼ (Submits proof to backend / Soroban verifier)
Soroban Verifier validates proof and logs settlement
   │
   ▼ (Signals success status)
Payee receives receipt in chat, Explorer link becomes active
```

---

## Local Testing & Deployment

To deploy the Soroban contracts locally:

1. **Start the local sandbox:**
   ```bash
   stellar sandbox start
   ```
2. **Build the contract:**
   ```bash
   cd contracts/stellar
   cargo build --target wasm32-unknown-unknown --release
   ```
3. **Deploy to Testnet:**
   ```bash
   stellar contract deploy \
     --wasm target/wasm32-unknown-unknown/release/stellchat_payment_verifier.wasm \
     --source admin_key \
     --network testnet
   ```
