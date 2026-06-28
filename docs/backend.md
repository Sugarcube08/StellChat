# StellChat Backend Architecture

The backend serves as a stateless router and realtime coordination hub. It does not store plaintext message contents or private keys, adhering to the platform's E2EE structure.

---

## Technical Stack

- **Core Framework:** NestJS (TypeScript)
- **Database Persistence:** PostgreSQL (Managed via TypeORM)
- **Caching & Pub/Sub:** Redis (Real-time events, typing indicators, presence)
- **Containerization:** Docker & Docker Compose

---

## Database Architecture

We utilize TypeORM mapped to a PostgreSQL instance.

### Entities

1. **`User` / `WalletLink` (`wallet_links`):** Mappings between cryptographic User IDs (X25519 public keys) and Stellar addresses.
2. **`PaymentRequest` (`payment_requests`):** Log of payment requests sent, assets, pending/approved statuses, and transaction hashes.
3. **`Payment` (`payments`):** Settled payment records linking transactions, status fields, and users.
4. **`ProofRecord` (`proof_records`):** Mapped SnarkJS JSON proofs and public signals stored for validation audits.
5. **`Message` (`messages`):** Mappings of envelopes to device recipient mailboxes.
6. **`Device` (`devices`):** Registered push notification and websocket tokens.

---

## Redis Real-Time Communication

Redis handles ephemeral, speed-sensitive events:
1. **WebSocket Event Propagation:** User typing signals and status adjustments are routed through Redis channels.
2. **Online Status / Presence:** Active sockets maintain a heartbeat key.
3. **Inbox Synchronization:** Signals are broadcast to trigger background sync fetches.

---

## API Endpoints

### Payment Router (`/api/payment`)

- **`POST /wallet-link`**
  - Links a user's ID with a Stellar address.
  - Body: `{ publicId: string, stellarAddress: string }`
- **`GET /wallet-link/:publicId`**
  - Mapped Stellar key lookup.
- **`POST /request`**
  - Logs a payment request event and propagates via Redis pub/sub.
  - Body: `{ senderId: string, recipientId: string, amount: string, asset: string }`
- **`POST /submit`**
  - Associates transaction receipt hash.
  - Body: `{ requestId: string, txHash: string }`
- **`POST /verify-proof`**
  - Initiates ZK verification.
  - Body: `{ paymentId: string, proof: object, publicSignals: array }`
