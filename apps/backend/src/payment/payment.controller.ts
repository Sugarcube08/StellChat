import {
  Controller,
  Post,
  Body,
  Get,
  Param,
  BadRequestException,
} from "@nestjs/common";
import { PaymentService } from "./payment.service";

@Controller("api/payment")
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post("wallet-link")
  async associateWallet(
    @Body("publicId") publicId: string,
    @Body("stellarAddress") stellarAddress: string,
  ) {
    if (!publicId || !stellarAddress) {
      throw new BadRequestException("publicId and stellarAddress are required");
    }
    return await this.paymentService.associateWallet(publicId, stellarAddress);
  }

  @Get("wallet-link/:publicId")
  async getWalletAddress(@Param("publicId") publicId: string) {
    const address = await this.paymentService.getWalletAddress(publicId);
    return { stellarAddress: address };
  }

  @Post("request")
  async createPaymentRequest(
    @Body("senderId") senderId: string,
    @Body("recipientId") recipientId: string,
    @Body("amount") amount: string,
    @Body("asset") asset?: string,
  ) {
    if (!senderId || !recipientId || !amount) {
      throw new BadRequestException(
        "senderId, recipientId, and amount are required",
      );
    }
    return await this.paymentService.createPaymentRequest(
      senderId,
      recipientId,
      amount,
      asset,
    );
  }

  @Post("submit")
  async submitPayment(
    @Body("requestId") requestId: string,
    @Body("txHash") txHash: string,
  ) {
    if (!requestId || !txHash) {
      throw new BadRequestException("requestId and txHash are required");
    }
    return await this.paymentService.submitPayment(requestId, txHash);
  }

  @Post("verify-proof")
  async verifyPaymentProof(
    @Body("paymentId") paymentId: string,
    @Body("proof") proof: Record<string, any>,
    @Body("publicSignals") publicSignals: string[],
  ) {
    if (!paymentId || !proof || !publicSignals) {
      throw new BadRequestException(
        "paymentId, proof, and publicSignals are required",
      );
    }
    const success = await this.paymentService.verifyPaymentProof(
      paymentId,
      proof,
      publicSignals,
    );
    return { success };
  }
}
