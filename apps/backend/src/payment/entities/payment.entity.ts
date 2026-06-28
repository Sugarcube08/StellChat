import { Entity, Column, PrimaryColumn, CreateDateColumn } from "typeorm";

@Entity("wallet_links")
export class WalletLinkEntity {
  @PrimaryColumn("varchar")
  public_id: string; // The user's cryptographic identity ID

  @Column("varchar")
  stellar_address: string; // The associated Stellar public key (G...)

  @CreateDateColumn()
  created_at: Date;
}

@Entity("payment_requests")
export class PaymentRequestEntity {
  @PrimaryColumn("uuid")
  id: string;

  @Column("varchar")
  sender_id: string; // Who requests the payment

  @Column("varchar")
  recipient_id: string; // Who pays

  @Column("varchar")
  amount: string; // Amount in XLM or USDC

  @Column("varchar", { default: "XLM" })
  asset: string;

  @Column("varchar", { default: "PENDING" })
  status: string; // PENDING, APPROVED, SUBMITTED, REJECTED

  @Column("varchar", { nullable: true })
  tx_hash: string | null;

  @CreateDateColumn()
  created_at: Date;
}

@Entity("payments")
export class PaymentEntity {
  @PrimaryColumn("uuid")
  id: string;

  @Column("varchar")
  sender_id: string;

  @Column("varchar")
  recipient_id: string;

  @Column("varchar")
  amount: string;

  @Column("varchar")
  asset: string;

  @Column("varchar")
  tx_hash: string;

  @Column("varchar", { default: "PENDING" })
  status: string; // PENDING, PROVEN, SETTLED

  @CreateDateColumn()
  created_at: Date;
}

@Entity("proof_records")
export class ProofRecordEntity {
  @PrimaryColumn("uuid")
  id: string;

  @Column("uuid")
  payment_id: string;

  @Column("jsonb")
  proof: Record<string, any>; // SnarkJS Groth16 proof json representation

  @Column("jsonb")
  public_signals: string[]; // Public signals

  @Column("boolean", { default: false })
  verified: boolean;

  @CreateDateColumn()
  created_at: Date;
}
