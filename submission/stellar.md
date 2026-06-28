# Stellar Blockchain Integration

StellChat interacts directly with the Stellar Network via Horizon RPC nodes.

## Key Actions
- **Wallet Connection:** Signs a backend-provided nonce challenge with the private key.
- **Payment submission:** Builds a payment operation using `PaymentOperationBuilder`, signs it, and executes ledger submission.
