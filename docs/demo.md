# StellChat Hackathon Demo Flow

This document details the step-by-step developer demonstration flow of StellChat. The entire user journey runs in a dark-mode, minimal interface and can be completed comfortably within three minutes.

---

## 3-Minute Demo Sequence

### Step 1: Connect Stellar Wallet
1. Open the **StellChat App** and navigate to the third tab **Wallet**.
2. Click **Connect Wallet** (simulates Freighter/Albedo browser popup).
3. The dashboard populates with:
   - Wallet Address: `GD7OQ4KRLDWR3B5MX43NBLF2J7J37A2C7L6E2QPL47G53WJ735STELL`
   - XLM Balance: `245.50 XLM`
   - USDC Balance: `$80.00`

### Step 2: Open a Conversation & Send Message
1. Navigate to the **Messages** tab.
2. Select **Alice** (or click add button to search for contact ID).
3. Send a chat message: *"Hey Alice, settling my share of the hackathon VPS fee now."*
4. Tick marks turn double-blue to verify E2EE delivery.

### Step 3: Request Payment
1. Click the **Wallet Icon** (next to attachments) in the composer input bar.
2. The payment bottom sheet launches.
3. Select asset **USDC** and enter amount **15.00**.
4. Click **Send Payment Request**.
5. A Stellar Payment card immediately prints in the conversation timeline showing `15.00 USDC` with a status of `PENDING APPROVAL`.

### Step 4: Payer Approval & On-Chain Settlement
1. On the recipient's view (or simulated within the chat interface), Alice clicks **APPROVE & PAY**.
2. The card updates dynamically through three live ledger milestones:
   - 🔄 *Submitting transaction to Stellar...* (Simulates broadcast to Horizon testnet)
   - 🔒 *Generating Zero-Knowledge Proof...* (Runs Poseidon hasher witness calculation)
   - 🛡️ *Verifying proof on Soroban...* (Invokes smart contract verifier)
3. Upon success, the payment card displays a green shield with **ZK VERIFIED** badge.

### Step 5: Explore the Ledger
1. Click **EXPLORE** on the verified payment card.
2. The app shows the receipt detailing the transaction hash `8cf5beecf3a479b1897e937d2f8b50e386ebf48a97573fbf4f2db0e271424eb0`.
3. Click **Explore Ledger** to open the Stellar Explorer page.
