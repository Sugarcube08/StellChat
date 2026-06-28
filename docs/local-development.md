# StellChat — Local Development Laboratory Guide

StellChat is configured with a fully self-contained local blockchain laboratory. Developers do not need external dependencies or public testnet access to test end-to-end messaging, transaction building, or zero-knowledge proof verification.

## 1. Prerequisites
Ensure you have the following installed on your host system:
- **Docker & Docker Compose** (for hosting databases, ledger nodes, and provers)
- **Node.js & NPM** (for backend services and compiling circuits)
- **Stellar CLI** (specifically version 20+, for compiling/deploying Soroban contracts)
- **Rust & Cargo** (with the `wasm32-unknown-unknown` target configured)
- **Flutter SDK** (for the mobile application)

---

## 2. Bootstrapping the Laboratory
You can boot the entire stack with a single command:
```bash
# Run the local bootstrap script
chmod +x ./scripts/dev.sh
./scripts/dev.sh
```

### What this script does programmatically:
1. **ZK Circuit Compilation:** Invokes `scripts/setup_zk.sh` to download the `circom` binary, compile `zk/circuits/payment_hasher.circom`, run the SnarkJS Plonk setup, and output the verification key.
2. **Soroban Compilation:** Triggers Cargo release builds targeting WASM.
3. **Docker Compose Orchestration:** Starts Postgres, Redis, MinIO, the local Stellar Horizon Quickstart node, the prover service, and the NestJS backend on `stellchat_local_net`.
4. **Stellar Admin Setup:** Generates a standalone network admin address, funds it via the local Friendbot ledger, and deploys the compiled verifier smart contract.
5. **Configuration Propagation:** Writes the new contract ID to the backend and restarts the NestJS and prover containers to apply changes.

---

## 3. Connecting to the Local Lab
- **Relay Backend:** `http://localhost:3000` (WebSockets + REST)
- **Horizon API:** `http://localhost:8000`
- **Soroban RPC:** `http://localhost:8000/soroban/rpc`
- **Friendbot (Local Funding):** `http://localhost:8000/friendbot?addr=<wallet>`
- **Prover API:** `http://localhost:5001`
- **MinIO Dashboard:** `http://localhost:9001` (User: `minioadmin`, Pass: `minioadmin`)
