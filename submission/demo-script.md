# StellChat — Live Demo Script

Follow these steps to demonstrate the end-to-end flow of StellChat to judges:

## Step 1: Environment Reset
Show the clean state.
```bash
make reset-demo
```

## Step 2: Onboarding
1. Open the mobile app. The cold start displays a premium space background with drifting stars.
2. Click **Connect Stellar Wallet**.
3. The app generates a random, pre-funded Stellar address on standalone and logs in with a verified signature challenge.

## Step 3: Messaging & Payment Request
1. Open the chat room for `Bob`.
2. Send a message. Notice it delivers instantly via WebSockets.
3. Click the payment action, choose **10.0 XLM**, and click **Send Payment Request**.
4. The payment request bubble appears in the chat.

## Step 4: Approval & ZK Verification
1. On Bob's device, click **Pay 10.0 XLM**.
2. Bob signs the transaction, which is submitted to Horizon.
3. Once the ledger confirms, Bob's client requests the prover service to generate a ZK proof.
4. The backend invokes the Soroban verifier contract.
5. The verified badge appears in the conversation under 2 seconds!
