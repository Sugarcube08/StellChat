import {
  Controller,
  Get,
  Post,
  Query,
  Body,
  HttpCode,
  HttpStatus,
} from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller("api/auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get("nonce")
  async getNonce(@Query("address") address: string) {
    const nonce = await this.authService.generateNonce(address);
    return { nonce };
  }

  @Post("login")
  @HttpCode(HttpStatus.OK)
  async login(
    @Body("address") address: string,
    @Body("signature") signature: string,
    @Body("nonce") nonce: string,
    @Body("provider") provider = "stellar",
    @Body("type") type = "wallet",
    @Body("network") network = "testnet",
  ) {
    const result = await this.authService.verifySignatureAndLogin(
      address,
      signature,
      nonce,
      provider,
      type,
      network,
    );
    return result;
  }
}
