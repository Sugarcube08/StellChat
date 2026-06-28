# StellChat — Hackathon Demo Runbook

This runbook guides presenters and judges through deploying and demonstrating StellChat under presentation conditions.

---

## 1. System Requirements & Startup
Ensure Docker and the Stellar CLI are running. Execute the following command to start with a clean state:
```bash
make reset-demo
```
**Expected startup time:** 30–45 seconds. The script waits for health probes on Horizon (`http://localhost:8000`), Postgres (`port 5432`), Redis (`port 6379`), and MinIO (`port 9000`) before running deployments.

---

## 2. Walkthrough Guide
1. **Wallet Sign-In:** 
   - Opening the client displays the cold-start Star Field.
   - Click **Connect Stellar Wallet** to trigger the embedded account generation and register the public address on the NestJS backend with a cryptographic signature challenge.
2. **Instant Messaging:** 
   - Send messages between mock accounts. All packets deliver in under 50ms via our Socket.io relay container.
3. **Soroban ZK Payments:** 
   - Alice requests XLM. Bob clicks pay.
   - The payer signs the transaction, submitting it to the Horizon ledger.
   - Bob's client queries the snarkjs container (`port 5001`) to generate the PLONK proof of the payment commitment, taking ~1.5 seconds.
   - The proof is submitted to the backend, which invokes the on-chain verifier (`verify_and_settle`) on the Soroban quickstart node. The receipt resolves immediately.

---

## 3. Troubleshooting & Recovery

### Issue A: "Account not found on ledger"
- **Cause:** Standalone network accounts must be funded before receiving transactions.
- **Resolution:** The mobile client automatically catches 404 ledger errors and triggers Friendbot funding. To manually trigger Friendbot funding, query:
  `curl -s "http://localhost:8000/friendbot?addr=<wallet-address>"`

### Issue B: WebSocket connection drops
- **Cause:** Local network interfaces resetting.
- **Resolution:** The client implements an exponential backoff reconnect policy. If disconnected, toggle the Wi-Fi or restart the mobile client. The session remains cached in secure storage and will automatically reconnect.

### Issue C: "Prover timeout or missing WASM/zkey"
- **Cause:** Prover service loaded before ZK compiler finished.
- **Resolution:** Re-run `make reset-demo` to ensure all SnarkJS setup steps compile sequentially.
