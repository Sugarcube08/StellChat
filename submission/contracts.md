# Soroban Contracts

The verifier smart contract is written in Rust and deployed on-chain on our standalone ledger.

## Contract Code: `contracts/stellar/src/lib.rs`
It exposes two primary functions:
- `authorize_payment(payment_id, sender, receiver, amount, proof_hash)`: Replay-protected registration.
- `verify_and_settle(payment_id, zk_proof)`: Marks the payment request as settled on-chain and publishes a `settled` symbol event.
