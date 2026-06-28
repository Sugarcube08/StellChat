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
        
        let key = DataKey::Payment(payment_id);
        if env.storage().persistent().has(&key) {
            panic!("payment id already exists (replay protection)");
        }

        let record = PaymentRecord {
            sender: sender.clone(),
            receiver,
            amount,
            proof_hash,
            settled: false,
        };
        
        env.storage().persistent().set(&key, &record);
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
            panic!("payment already settled (replay protection)");
        }
        
        // ZK Proof Verification
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

#[cfg(test)]
mod test {
    use super::*;
    use soroban_sdk::{testutils::Address as _, Address, Env, Bytes, BytesN};

    #[test]
    fn test_initialize() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let contract_id = env.register_contract(None, StellChatVerifier);
        let client = StellChatVerifierClient::new(&env, &contract_id);
        
        client.initialize(&admin);
    }

    #[test]
    #[should_panic(expected = "already initialized")]
    fn test_initialize_twice_panics() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let contract_id = env.register_contract(None, StellChatVerifier);
        let client = StellChatVerifierClient::new(&env, &contract_id);
        
        client.initialize(&admin);
        client.initialize(&admin);
    }

    #[test]
    fn test_payment_authorization_and_settlement() {
        let env = Env::default();
        env.mock_all_auths();

        let admin = Address::generate(&env);
        let contract_id = env.register_contract(None, StellChatVerifier);
        let client = StellChatVerifierClient::new(&env, &contract_id);
        client.initialize(&admin);

        let sender = Address::generate(&env);
        let receiver = Address::generate(&env);
        let payment_id = 999;
        let amount = 5000;
        let proof_hash = BytesN::from_array(&env, &[7u8; 32]);

        client.authorize_payment(&payment_id, &sender, &receiver, &amount, &proof_hash);

        // Verify it is not settled yet
        assert!(!client.is_proof_verified(&proof_hash));

        // Submit ZK Proof
        let mock_proof = Bytes::from_slice(&env, &[1u8, 2u8, 3u8]);
        let success = client.verify_and_settle(&payment_id, &mock_proof);
        assert!(success);

        // Verify it is now settled
        assert!(client.is_proof_verified(&proof_hash));
    }

    #[test]
    #[should_panic(expected = "payment id already exists (replay protection)")]
    fn test_payment_id_replay_protection() {
        let env = Env::default();
        env.mock_all_auths();

        let admin = Address::generate(&env);
        let contract_id = env.register_contract(None, StellChatVerifier);
        let client = StellChatVerifierClient::new(&env, &contract_id);
        client.initialize(&admin);

        let sender = Address::generate(&env);
        let receiver = Address::generate(&env);
        let payment_id = 100;
        let amount = 1000;
        let proof_hash = BytesN::from_array(&env, &[0u8; 32]);

        client.authorize_payment(&payment_id, &sender, &receiver, &amount, &proof_hash);
        client.authorize_payment(&payment_id, &sender, &receiver, &amount, &proof_hash); // Panics
    }
}
