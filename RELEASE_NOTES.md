# Release Notes — StellChat v1.0.0-hackathon

We are thrilled to release **StellChat v1.0.0-hackathon**, a production-grade, privacy-first ephemeral messaging client powered by Stellar payments and zero-knowledge verification.

## Key Features
1. **Wallet-Centric Identity:** Completely removed local identity architectures. The wallet address is the exclusive cryptographic user id.
2. **Soroban Verifier:** Zero-knowledge proof verification contract deployed on-chain on local standalone ledger.
3. **Plonk Proving Microservice:** Poseidon-based payment hasher generating proofs in less than 2 seconds.
4. **S3 Presigned Media Storage:** Media files are uploaded directly to MinIO using pre-signed bucket tokens.
5. **Observability & Logging:** Structured traces bound to a correlation ID for ledger confirmations, proofs, and WebSockets.
