# StellChat — Operations & Production Deployment Guide

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
