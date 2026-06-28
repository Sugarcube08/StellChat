# Zero-Knowledge payment verification

StellChat utilizes Zero-Knowledge (ZK) proofs to preserve transaction privacy while ensuring payment verifiability inside end-to-end encrypted conversations. This architecture allows a payer to prove they successfully completed a specific Stellar transaction without revealing their identity, account balance, or transaction details to the public relay.

---

## The Privacy Problem

When Alice pays Bob inside a chat:
- If she sends a raw Stellar Transaction Hash (TX Hash) over the relay, the relay owner can associate Alice and Bob's public keys with their Stellar addresses.
- If she publishes the TX Hash on a public board, third-party eavesdroppers can link chat identities to real-world balances.

## The StellChat Solution

By introducing ZK proofs:
1. Alice transfers USDC or XLM to Bob on-chain.
2. Alice generates a local proof showing she possesses a valid transaction matching:
   - Secret blinding factor
   - Recipient address hash
   - Specific transfer amount
3. She publishes a **Public Commitment Hash** (Poseidon hash of the transaction components).
4. The smart contract and Bob verify the Groth16 proof against the Public Commitment Hash.
5. The payment receipt is verified without revealing Alice's Stellar address or direct inputs to the relay.

---

## Circuit Design (`zk/circuits/payment_hasher.circom`)

StellChat compiles a custom Circom circuit that constraints payment inputs:

- **Private Inputs:**
  - `sender_private_key`: Used to verify the ownership of the source account.
  - `recipient_stellar_addr_hash`: Hash of the destination Stellar wallet.
  - `amount`: Transaction amount.
  - `blinding_factor`: Entropy added to prevent dictionary attacks.
- **Public Inputs:**
  - `payment_hash_commitment`: Poseidon hash of private parameters published to the ledger.
- **Verification Rule:**
  - `hash_out === payment_hash_commitment` (Constrains that calculated Poseidon hash matches public input).

---

## Proof Generation & Verification Workflow

```
[Payer Client] -> Run snarkjs to calculate witness and generate proof:
   witness.wtns = generate_witness(payment_hasher.wasm, input.json)
   proof.json, public.json = groth16.prove(payment_hasher.zkey, witness.wtns)

[Backend/Contract] -> Run verifier:
   groth16.verify(verification_key.json, public.json, proof.json) -> SUCCESS
```

For the hackathon, we supply:
- `zk/circuits/payment_hasher.circom`: The Circom code.
- `zk/verifier/verifier.go`: A high-performance Go-based verifier service which parses SnarkJS inputs and mimics the Groth16 verify pairing.
