#!/bin/bash
set -e

# Base directories
REPO_DIR="/home/sugarcube/Desktop/Documents/Code-Server/Hackathon Projects/Stellar-DH/StellChat"
cd "$REPO_DIR"

echo "============================================="
echo " StellChat Local Laboratory Bootstrap"
echo "============================================="

# 1. Compile ZK circuit and setup proving keys
echo "--> Compiling ZK Circuits..."
chmod +x ./scripts/setup_zk.sh
./scripts/setup_zk.sh

# 2. Compile contract (Cargo is already built, but verify target exists)
echo "--> Compiling Soroban Smart Contract..."
cd contracts/stellar
cargo build --target wasm32v1-none --release
stellar contract optimize --wasm target/wasm32v1-none/release/stellchat_payment_verifier.wasm
cd "$REPO_DIR"

# 3. Boot docker compose stack
echo "--> Booting local laboratory Docker containers..."
docker compose -f docker-compose.local.yml up -d

# 4. Wait for services to be ready
echo "--> Waiting for Postgres..."
until docker exec stellchat-postgres-local pg_isready -U postgres -d stellchat > /dev/null; do
  sleep 1
done

echo "--> Waiting for local Stellar Quickstart ledger..."
until curl -s http://localhost:8000/ > /dev/null; do
  sleep 2
done
echo "Stellar Horizon is online! Sleeping 15 seconds to let ledger core initialize..."
sleep 15

echo "--> Waiting for MinIO object storage..."
until curl -s http://localhost:9000/minio/health/live > /dev/null; do
  sleep 1
done
echo "MinIO object storage is online!"

# 5. Deploy contract to standalone network
echo "--> Deploying Soroban smart contract..."
STELLAR_CLI="/home/sugarcube/.local/bin/stellar"

# Add standalone network configuration to host CLI if not exists
$STELLAR_CLI network add standalone \
  --rpc-url "http://localhost:8000/soroban/rpc" \
  --network-passphrase "Standalone Network ; February 2017" || true

# Setup admin account
$STELLAR_CLI keys generate admin --network standalone || true
ADMIN_ADDR=$($STELLAR_CLI keys address admin)

echo "Funding local administrator address ($ADMIN_ADDR)..."
curl -s "http://localhost:8000/friendbot?addr=$ADMIN_ADDR" > /dev/null
sleep 10

# Deploy contract directly from the host
CONTRACT_ID=$($STELLAR_CLI contract deploy \
  --wasm contracts/stellar/target/wasm32v1-none/release/stellchat_payment_verifier.optimized.wasm \
  --source admin \
  --network standalone)

echo "Smart Contract deployed successfully!"
echo "Contract ID: $CONTRACT_ID"

# Save contract ID locally for the NestJS backend and mobile app to load
echo "$CONTRACT_ID" > apps/backend/src/payment/contract_id.txt

echo "--> Copying contract ID into backend container..."
docker exec stellchat-backend-local mkdir -p /usr/src/app/dist/payment /usr/src/app/src/payment || true
docker cp apps/backend/src/payment/contract_id.txt stellchat-backend-local:/usr/src/app/dist/payment/contract_id.txt || true
docker cp apps/backend/src/payment/contract_id.txt stellchat-backend-local:/usr/src/app/src/payment/contract_id.txt || true

# 6. Initialize contract
echo "--> Initializing smart contract on-chain..."
$STELLAR_CLI contract invoke \
  --id "$CONTRACT_ID" \
  --source admin \
  --network standalone \
  -- \
  initialize \
  --admin "$ADMIN_ADDR"

echo "Smart Contract initialized!"

# 7. Restart prover and backend to pick up compiled keys & contract id
echo "--> Syncing containers..."
docker compose -f docker-compose.local.yml restart prover backend

echo "============================================="
echo " StellChat local laboratory is online!"
echo "============================================="
echo "Horizon Endpoint:     http://localhost:8000"
echo "Soroban RPC:          http://localhost:8000/soroban/rpc"
echo "Friendbot Funding:    http://localhost:8000/friendbot"
echo "Relay Backend:        http://localhost:3000"
echo "Prover Service:       http://localhost:5001"
echo "============================================="
echo "Run 'cd apps/mobile && flutter run' to launch the client."
