pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";

template PaymentHasher() {
    // Private Inputs
    signal input sender_private_key;
    signal input recipient_stellar_addr_hash;
    signal input amount;
    signal input blinding_factor;

    // Public Inputs
    signal input payment_hash_commitment;

    // Outputs
    signal output hash_out;

    // Calculate Poseidon Hash of inputs
    component hasher = Poseidon(4);
    hasher.inputs[0] <== sender_private_key;
    hasher.inputs[1] <== recipient_stellar_addr_hash;
    hasher.inputs[2] <== amount;
    hasher.inputs[3] <== blinding_factor;

    hash_out <== hasher.out;

    // Constrain that computed hash matches public commitment
    hash_out === payment_hash_commitment;
}

component main {public [payment_hash_commitment]} = PaymentHasher();
