const express = require("express");
const snarkjs = require("snarkjs");
const circomlibjs = require("circomlibjs");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 5001;

// Path to compiled circuit WASM and zkey proving key
const WASM_PATH = process.env.WASM_PATH || path.join(__dirname, "../../zk/build/payment_hasher_js/payment_hasher.wasm");
const ZKEY_PATH = process.env.ZKEY_PATH || path.join(__dirname, "../../zk/build/payment_hasher_final.zkey");
const VKEY_PATH = process.env.VKEY_PATH || path.join(__dirname, "../../zk/build/verification_key.json");

let poseidon;
async function getPoseidon() {
  if (!poseidon) {
    poseidon = await circomlibjs.buildPoseidon();
  }
  return poseidon;
}

// Pre-initialize Poseidon
getPoseidon().then(() => {
  console.log("[Prover] Poseidon hash function initialized");
}).catch(err => {
  console.error("[Prover] Failed to initialize Poseidon:", err);
});

app.get("/health", (req, res) => {
  const hasWasm = fs.existsSync(WASM_PATH);
  const hasZkey = fs.existsSync(ZKEY_PATH);
  
  res.json({
    status: "UP",
    wasm: hasWasm ? "OK" : "MISSING",
    zkey: hasZkey ? "OK" : "MISSING",
    ready: hasWasm && hasZkey
  });
});

app.post("/prove", async (req, res) => {
  console.log("[Prover] Received proof request:", req.body);
  
  const {
    sender_private_key,
    recipient_stellar_addr_hash,
    amount,
    blinding_factor
  } = req.body;

  if (!sender_private_key || !recipient_stellar_addr_hash || !amount || !blinding_factor) {
    return res.status(400).json({ error: "Missing required circuit inputs" });
  }

  // Double check assets exist
  if (!fs.existsSync(WASM_PATH) || !fs.existsSync(ZKEY_PATH)) {
    return res.status(500).json({
      error: "ZK proving assets not initialized. Compile circuits first.",
      wasmExists: fs.existsSync(WASM_PATH),
      zkeyExists: fs.existsSync(ZKEY_PATH)
    });
  }

  try {
    const p = await getPoseidon();
    
    // Hash elements must be bounded within BN128 scalar field
    const pHash = p([
      BigInt(sender_private_key),
      BigInt(recipient_stellar_addr_hash),
      BigInt(amount),
      BigInt(blinding_factor)
    ]);
    const computedCommitment = p.F.toString(pHash);
    console.log("[Prover] Calculated Poseidon commitment:", computedCommitment);

    const inputs = {
      sender_private_key: String(sender_private_key),
      recipient_stellar_addr_hash: String(recipient_stellar_addr_hash),
      amount: String(amount),
      blinding_factor: String(blinding_factor),
      payment_hash_commitment: computedCommitment
    };

    console.log("[Prover] Executing SnarkJS Plonk prove...");
    const { proof, publicSignals } = await snarkjs.plonk.fullProve(
      inputs,
      WASM_PATH,
      ZKEY_PATH
    );

    console.log("[Prover] Proof generated successfully!");
    res.json({
      proof,
      publicSignals
    });
  } catch (err) {
    console.error("[Prover] Error generating proof:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/verify", async (req, res) => {
  console.log("[Prover] Received verification request");
  const { proof, publicSignals } = req.body;
  if (!proof || !publicSignals) {
    return res.status(400).json({ error: "Missing proof or publicSignals" });
  }
  const vKeyPath = VKEY_PATH;
  if (!fs.existsSync(vKeyPath)) {
    return res.status(500).json({ error: `Verification key not found at ${vKeyPath}. Run setup_zk.sh first.` });
  }
  try {
    const vKey = JSON.parse(fs.readFileSync(vKeyPath, "utf8"));
    const verified = await snarkjs.plonk.verify(vKey, publicSignals, proof);
    console.log("[Prover] ZK verification result:", verified);
    res.json({ success: verified });
  } catch (err) {
    console.error("[Prover] Error verifying proof:", err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`[Prover] Prover microservice running on port ${PORT}`);
  console.log(`[Prover] Target WASM path: ${WASM_PATH}`);
  console.log(`[Prover] Target ZKEY path: ${ZKEY_PATH}`);
});
