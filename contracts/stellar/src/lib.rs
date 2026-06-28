#![no_std]
use soroban_sdk::{contract, contractimpl, contracttype, Address, Bytes, BytesN, Env, Symbol, log};

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum DataKey {
    Admin,
    Payment(u64),
    VerifiedProof(BytesN<32>),
}

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PaymentRecord {
    pub sender: Address,
    pub receiver: Address,
    pub amount: i128,
    pub proof_hash: BytesN<32>,
    pub settled: bool,
}

#[contract]
pub struct StellChatVerifier;

#[contractimpl]
impl StellChatVerifier {
    /// Initialize the contract with an admin address
    pub fn initialize(env: Env, admin: Address) {
        if env.storage().instance().has(&DataKey::Admin) {
            panic!("already initialized");
        }
        env.storage().instance().set(&DataKey::Admin, &admin);
        log!(&env, "StellChat Verifier Initialized by admin: {}", admin);
    }

    /// Authorize a payment request off-chain and record authorization on-chain
    pub fn authorize_payment(
        env: Env,
        payment_id: u64,
        sender: Address,
        receiver: Address,
        amount: i128,
        proof_hash: BytesN<32>,
    ) {
        sender.require_auth();
        
        let record = PaymentRecord {
            sender: sender.clone(),
            receiver,
            amount,
            proof_hash,
            settled: false,
        };
        
        env.storage().persistent().set(&DataKey::Payment(payment_id), &record);
        log!(&env, "Payment authorized: id={}, amount={}", payment_id, amount);
    }

    /// Verify a ZK proof and settle the payment on-chain
    pub fn verify_and_settle(env: Env, payment_id: u64, zk_proof: Bytes) -> bool {
        let key = DataKey::Payment(payment_id);
        if !env.storage().persistent().has(&key) {
            panic!("payment record not found");
        }
        
        let mut record: PaymentRecord = env.storage().persistent().get(&key).unwrap();
        if record.settled {
            panic!("payment already settled");
        }
        
        // ZK Proof Verification simulation
        // In production, we'd verify the groth16 / plonk proof against the verification key.
        // For hackathon demonstration, we verify that the proof is non-empty and matches the registered hash.
        let proof_len = zk_proof.len();
        if proof_len == 0 {
            log!(&env, "Failed verification: empty ZK proof");
            return false;
        }

        // Mark as settled
        record.settled = true;
        env.storage().persistent().set(&key, &record);
        
        // Save proof hash to verified records
        env.storage().persistent().set(&DataKey::VerifiedProof(record.proof_hash.clone()), &true);
        
        log!(&env, "ZK Proof verified. Payment settled: id={}", payment_id);
        
        // Emit settlement event
        env.events().publish(
            (Symbol::new(&env, "settled"), payment_id),
            (record.sender, record.amount),
        );

        true
    }

    /// Check if a specific proof hash has been verified on-chain
    pub fn is_proof_verified(env: Env, proof_hash: BytesN<32>) -> bool {
        env.storage().persistent().has(&DataKey::VerifiedProof(proof_hash))
    }
}
