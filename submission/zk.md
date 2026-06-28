# Zero-Knowledge Circuit

StellChat utilizes Poseidon hashing inside a Groth16 Plonk circuit to verify payments off-chain and commit the verification state on-chain.

## Circuit inputs:
- **Private:** `sender_private_key`, `recipient_stellar_addr_hash`, `amount`, `blinding_factor`.
- **Public:** `payment_hash_commitment`.
