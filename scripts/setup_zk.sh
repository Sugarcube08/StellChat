#!/bin/bash
set -e

# Create bin and zk output directories
mkdir -p zk/bin zk/build

# Get target OS for circom binary
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH_TYPE=$(uname -m)

echo "Detecting architecture... OS: $OS_TYPE, Arch: $ARCH_TYPE"

# Download circom compiler if not present
if [ ! -f zk/bin/circom ]; then
  echo "Downloading circom compiler..."
  if [ "$OS_TYPE" = "darwin" ]; then
    curl -L -o zk/bin/circom https://github.com/iden3/circom/releases/latest/download/circom-mac-amd64
  else
    curl -L -o zk/bin/circom https://github.com/iden3/circom/releases/latest/download/circom-linux-amd64
  fi
  chmod +x zk/bin/circom
fi

# Install snarkjs and circomlib locally at workspace root
echo "Installing SnarkJS and Circomlib node packages..."
npm install --no-audit --no-fund snarkjs circomlib

# Compile the circuit
echo "Compiling Circom circuit..."
./zk/bin/circom zk/circuits/payment_hasher.circom --wasm --r1cs --sym --output zk/build

# Run SnarkJS setup
echo "Setting up proving keys (PLONK)..."
# New trusted setup power of tau
npx snarkjs powersoftau new bn128 12 zk/build/pot12_0000.ptau -v
npx snarkjs powersoftau contribute zk/build/pot12_0000.ptau zk/build/pot12_0001.ptau --name="StellChat Contrib" -v -e="deterministic entropy text"
npx snarkjs powersoftau prepare phase2 zk/build/pot12_0001.ptau zk/build/pot12_final.ptau -v

# Setup PLONK
npx snarkjs plonk setup zk/build/payment_hasher.r1cs zk/build/pot12_final.ptau zk/build/payment_hasher_final.zkey

# Export verification key
npx snarkjs zkey export verificationkey zk/build/payment_hasher_final.zkey zk/build/verification_key.json

echo "ZK proving keys and compiled circuit artifacts generated in zk/build/"
