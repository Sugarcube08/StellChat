import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from "typeorm";

@Entity("users")
export class UserEntity {
  @PrimaryColumn("varchar")
  walletAddress: string;

  @Column("varchar")
  walletProvider: string;

  @Column("varchar")
  walletType: string;

  @Column("varchar")
  network: string;

  @Column("varchar", { nullable: true })
  displayName: string | null;

  @Column("varchar", { nullable: true })
  avatar: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  lastSeen: Date;
}
