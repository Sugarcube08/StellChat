import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { PaymentController } from "./payment.controller";
import { PaymentService } from "./payment.service";
import {
  WalletLinkEntity,
  PaymentRequestEntity,
  PaymentEntity,
  ProofRecordEntity,
} from "./entities/payment.entity";
import { RedisModule } from "../redis/redis.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([
      WalletLinkEntity,
      PaymentRequestEntity,
      PaymentEntity,
      ProofRecordEntity,
    ]),
    RedisModule,
  ],
  controllers: [PaymentController],
  providers: [PaymentService],
  exports: [PaymentService],
})
export class PaymentModule {}
