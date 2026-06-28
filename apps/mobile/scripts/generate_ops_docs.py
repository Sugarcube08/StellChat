import os

def generate_ops_docs():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.abspath(os.path.join(script_dir, "..", "..", ".."))
    docs_path = os.path.join(repo_root, "docs")
    os.makedirs(docs_path, exist_ok=True)

    # 1. local-development.md
    with open(os.path.join(docs_path, "local-development.md"), "w") as f:
        f.write('''# StellChat — Local Development Laboratory Guide

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
''')

    # 2. deployment.md
    with open(os.path.join(docs_path, "deployment.md"), "w") as f:
        f.write('''# StellChat — Operations & Production Deployment Guide

Deploying StellChat to a production environment requires replacing local quickstart services with highly available networks and storage services.

## 1. Environment Configurations
The backend relies on the following environment variables (defined in `.env` or Docker secrets):

| Variable | Description | Production Value Example |
|---|---|---|
| `NODE_ENV` | Environment mode | `production` |
| `DATABASE_URL` | Postgres Connection URI | `postgresql://user:pass@db-host:5432/db` |
| `REDIS_URL` | Redis Cache URI | `redis://default:pass@redis-host:6379` |
| `JWT_SECRET` | Signing secret for session tokens | *High entropy random string* |
| `R2_ACCESS_KEY_ID` | Storage Access Key | Cloudflare R2 / AWS S3 key ID |
| `R2_SECRET_ACCESS_KEY` | Storage Secret Key | Cloudflare R2 / AWS S3 secret key |
| `R2_ENDPOINT` | Presigned URL target endpoint | `https://<account-id>.r2.cloudflarestorage.com` |
| `R2_PUBLIC_ENDPOINT` | Public CDN serving uploads | `https://media.stellchat.com` |
| `R2_BUCKET_NAME` | Media target bucket | `stellchat-prod-attachments` |
| `STELLAR_NETWORK` | Target blockchain environment | `testnet` or `public` |

---

## 2. Deploying Smart Contracts
When moving to Stellar Testnet or Mainnet:
1. Build the release WASM:
   ```bash
   cargo build --target wasm32-unknown-unknown --release
   ```
2. Optimize the bytecode using the Soroban optimizer:
   ```bash
   stellar contract optimize --wasm target/wasm32-unknown-unknown/release/stellchat_payment_verifier.wasm
   ```
3. Deploy the optimized contract:
   ```bash
   stellar contract deploy --wasm target/wasm32-unknown-unknown/release/stellchat_payment_verifier.optimized.wasm --source <funding-key> --network testnet
   ```
4. Save the contract ID and write it to `apps/backend/src/payment/contract_id.txt`.
''')

    # 3. architecture.md
    with open(os.path.join(docs_path, "architecture.md"), "w") as f:
        f.write('''# StellChat — System Architecture

The following diagram outlines the messaging, payment, and zero-knowledge proof verification pipeline.

```mermaid
sequenceDiagram
    autonumber
    actor Alice as Alice (Sender)
    participant Prover as Prover Microservice
    participant Relay as StellChat Backend
    participant Horizon as Stellar Ledger / Horizon
    actor Bob as Bob (Receiver)

    Alice->>Relay: POST /api/payment/request (Ask Bob for 10 XLM)
    Relay-->>Bob: WebSocket: [PAYMENT_REQUEST]
    Bob->>Horizon: Submit transaction paying 10 XLM to Alice
    Horizon-->>Bob: Confirm TX on ledger (returns txHash)
    Bob->>Relay: POST /api/payment/submit (Report txHash)
    Relay-->>Alice: WebSocket: [PAYMENT_SUBMITTED]
    
    Bob->>Prover: POST /prove (Generate ZK Proof of payment inputs)
    Prover-->>Bob: Returns zkProof + publicSignals
    
    Bob->>Relay: POST /api/payment/verify-proof (Submit zkProof)
    Relay->>Horizon: Invoke Soroban Contract: verify_and_settle
    Horizon-->>Relay: Verified & Settled Event emitted
    Relay-->>Alice: WebSocket: [PAYMENT_SETTLED] (Verified Receipt!)
    Relay-->>Bob: WebSocket: [PAYMENT_SETTLED]
```
''')

    print("Created ops and architecture documentation under docs/!")

if __name__ == "__main__":
    generate_ops_docs()
