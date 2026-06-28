import { Injectable, Logger, Inject } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { WalletLinkEntity, PaymentRequestEntity, PaymentEntity, ProofRecordEntity } from "./entities/payment.entity";
import { v4 as uuidv4 } from "uuid";
import Redis from "ioredis";

@Injectable()
export class PaymentService {
  private readonly logger = new Logger(PaymentService.name);

  constructor(
    @InjectRepository(WalletLinkEntity)
    private readonly walletLinkRepo: Repository<WalletLinkEntity>,
    @InjectRepository(PaymentRequestEntity)
    private readonly paymentRequestRepo: Repository<PaymentRequestEntity>,
    @InjectRepository(PaymentEntity)
    private readonly paymentRepo: Repository<PaymentEntity>,
    @InjectRepository(ProofRecordEntity)
    private readonly proofRecordRepo: Repository<ProofRecordEntity>,
    @Inject("REDIS_CLIENT")
    private readonly redis: Redis,
  ) {}

  /// Associate a StellChat Public ID with a Stellar Wallet Address
  async associateWallet(publicId: string, stellarAddress: string): Promise<WalletLinkEntity> {
    this.logger.log(`Associating user ${publicId} with Stellar wallet ${stellarAddress}`);
    let link = await this.walletLinkRepo.findOne({ where: { public_id: publicId } });
    if (!link) {
      link = new WalletLinkEntity();
      link.public_id = publicId;
    }
    link.stellar_address = stellarAddress;
    return await this.walletLinkRepo.save(link);
  }

  /// Get the Stellar address associated with a user public key
  async getWalletAddress(publicId: string): Promise<string | null> {
    const link = await this.walletLinkRepo.findOne({ where: { public_id: publicId } });
    return link ? link.stellar_address : null;
  }

  /// Create a payment request within a chat conversation
  async createPaymentRequest(
    senderId: string,
    recipientId: string,
    amount: string,
    asset = "XLM",
  ): Promise<PaymentRequestEntity> {
    this.logger.log(`Payment Request: ${senderId} requests ${amount} ${asset} from ${recipientId}`);
    const req = new PaymentRequestEntity();
    req.id = uuidv4();
    req.sender_id = senderId;
    req.recipient_id = recipientId;
    req.amount = amount;
    req.asset = asset;
    req.status = "PENDING";

    const saved = await this.paymentRequestRepo.save(req);

    // Propagate transaction request through Redis for real-time signaling
    const eventPayload = {
      type: "PAYMENT_REQUEST",
      requestId: saved.id,
      senderId,
      amount,
      asset,
    };
    await this.redis.publish(`user:events:${recipientId}`, JSON.stringify(eventPayload));

    return saved;
  }

  /// Submit a payment receipt once the Stellar transaction succeeds
  async submitPayment(requestId: string, txHash: string): Promise<PaymentEntity> {
    const req = await this.paymentRequestRepo.findOne({ where: { id: requestId } });
    if (!req) {
      throw new Error("Payment request not found");
    }

    req.status = "SUBMITTED";
    req.tx_hash = txHash;
    await this.paymentRequestRepo.save(req);

    const payment = new PaymentEntity();
    payment.id = uuidv4();
    payment.sender_id = req.recipient_id; // The payer
    payment.recipient_id = req.sender_id; // The payee
    payment.amount = req.amount;
    payment.asset = req.asset;
    payment.tx_hash = txHash;
    payment.status = "PENDING";

    const savedPayment = await this.paymentRepo.save(payment);

    // Real-time notification to the receiver that transaction is submitted on Stellar
    await this.redis.publish(`user:events:${req.sender_id}`, JSON.stringify({
      type: "PAYMENT_SUBMITTED",
      paymentId: savedPayment.id,
      txHash,
    }));

    return savedPayment;
  }

  /// Verify ZK proof of payment on-chain/via Soroban logic and settle the transaction
  async verifyPaymentProof(
    paymentId: string,
    proof: Record<string, any>,
    publicSignals: string[],
  ): Promise<boolean> {
    this.logger.log(`Verifying ZK Proof for payment: ${paymentId}`);

    const payment = await this.paymentRepo.findOne({ where: { id: paymentId } });
    if (!payment) {
      throw new Error("Payment record not found");
    }

    // In a real-world implementation, we would spawn SnarkJS verification or query Soroban contract verifications.
    // For the hackathon demo, we simulate the verification of the Groth16 proof:
    const isMockVerified = proof && publicSignals && publicSignals.length > 0;

    const record = new ProofRecordEntity();
    record.id = uuidv4();
    record.payment_id = paymentId;
    record.proof = proof;
    record.public_signals = publicSignals;
    record.verified = isMockVerified;
    await this.proofRecordRepo.save(record);

    if (isMockVerified) {
      payment.status = "SETTLED";
      await this.paymentRepo.save(payment);

      const request = await this.paymentRequestRepo.findOne({ where: { tx_hash: payment.tx_hash } });
      if (request) {
        request.status = "APPROVED";
        await this.paymentRequestRepo.save(request);
      }

      this.logger.log(`Payment settled and verified: ${paymentId}`);

      // Signal settlement success to both sender and receiver
      const settlementSignal = {
        type: "PAYMENT_SETTLED",
        paymentId,
        txHash: payment.tx_hash,
        verified: true,
      };
      await this.redis.publish(`user:events:${payment.sender_id}`, JSON.stringify(settlementSignal));
      await this.redis.publish(`user:events:${payment.recipient_id}`, JSON.stringify(settlementSignal));
    }

    return isMockVerified;
  }
}
