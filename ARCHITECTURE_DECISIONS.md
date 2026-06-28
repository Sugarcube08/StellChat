# Architecture Decision Records (ADR)

## ADR 1: Connected Stellar Wallet as Sole Identity
- **Context:** Previous prototype used parallel device and recovery identities.
- **Decision:** Removed Ed25519/X25519 local device bootstrap and mapped identity exclusively to the Stellar Public Address.
- **Consequences:** Simplified recovery, unified account identity, eliminated redundant local storage keys.

## ADR 2: Standalone Prover Microservice
- **Context:** Performing SnarkJS Plonk proving on low-end mobile devices causes CPU spikes and slow rendering.
- **Decision:** Outsource witness and proof generation to a lightweight Node.js container on the relay server.
- **Consequences:** Proofs are generated instantly in <2 seconds with 0 mobile rendering performance degradation.
