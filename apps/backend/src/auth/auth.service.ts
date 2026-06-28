import {
  Injectable,
  Logger,
  Inject,
  BadRequestException,
  UnauthorizedException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { UserEntity } from "./entities/user.entity";
import Redis from "ioredis";
import { Keypair } from "stellar-sdk";
import * as crypto from "crypto";

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly jwtSecret =
    process.env.JWT_SECRET || "stellchat-auth-jwt-secret-key-42";

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @Inject("REDIS_CLIENT")
    private readonly redis: Redis,
  ) {}

  /// Generate a unique cryptographically secure nonce for a wallet address
  async generateNonce(address: string): Promise<string> {
    // Basic Stellar Address validation
    try {
      Keypair.fromPublicKey(address);
    } catch {
      throw new BadRequestException("Invalid Stellar address format");
    }

    const nonce = `StellChat Authentication Challenge: ${crypto.randomBytes(16).toString("hex")}`;

    // Store in Redis with a 5-minute TTL
    await this.redis.set(`auth:nonce:${address}`, nonce, "EX", 300);
    this.logger.log(`Generated challenge nonce for wallet: ${address}`);
    return nonce;
  }

  /// Verify the wallet signature against the challenge nonce
  async verifySignatureAndLogin(
    address: string,
    signature: string,
    nonce: string,
    provider: string,
    type: string,
    network: string,
  ): Promise<{ token: string; user: UserEntity }> {
    this.logger.log(`Processing login for address: ${address}`);

    // 1. Retrieve stored nonce
    const storedNonce = await this.redis.get(`auth:nonce:${address}`);
    if (!storedNonce || storedNonce !== nonce) {
      throw new UnauthorizedException(
        "Challenge expired or invalid. Please request a new nonce.",
      );
    }

    // 2. Verify signature using Stellar Keypair
    try {
      const kp = Keypair.fromPublicKey(address);
      const messageBuffer = Buffer.from(nonce);
      const signatureBuffer = Buffer.from(signature, "base64");

      const isValid = kp.verify(messageBuffer, signatureBuffer);
      if (!isValid) {
        throw new UnauthorizedException(
          "Invalid cryptographic signature for this wallet",
        );
      }
    } catch (err) {
      this.logger.error(
        `Signature verification failed: ${err instanceof Error ? err.message : String(err)}`,
      );
      throw new UnauthorizedException("Signature verification failed");
    }

    // Clear nonce after successful verification (replay protection)
    await this.redis.del(`auth:nonce:${address}`);

    // 3. Retrieve or create user record
    let user = await this.userRepo.findOne({
      where: { walletAddress: address },
    });
    if (!user) {
      user = new UserEntity();
      user.walletAddress = address;
      user.walletProvider = provider;
      user.walletType = type;
      user.network = network;
      this.logger.log(`Created new wallet-centric user record: ${address}`);
    } else {
      user.network = network;
    }
    user.lastSeen = new Date();
    await this.userRepo.save(user);

    // 4. Generate JWT-like signed session token
    const token = this.generateSessionToken(address);

    return { token, user };
  }

  /// Verify a session token and extract the wallet address
  verifySessionToken(token: string): string {
    try {
      const [payloadBase64, signature] = token.split(".");
      if (!payloadBase64 || !signature) {
        throw new Error("Malformed token structure");
      }

      const payloadString = Buffer.from(payloadBase64, "base64").toString(
        "utf8",
      );
      const expectedSignature = crypto
        .createHmac("sha256", this.jwtSecret)
        .update(payloadString)
        .digest("hex");

      if (signature !== expectedSignature) {
        throw new Error("Invalid signature signature");
      }

      const payload = JSON.parse(payloadString) as {
        address: string;
        exp: number;
      };
      if (payload.exp < Date.now()) {
        throw new Error("Session expired");
      }

      return payload.address;
    } catch {
      throw new UnauthorizedException("Invalid or expired session token");
    }
  }

  private generateSessionToken(address: string): string {
    const payload = JSON.stringify({
      address,
      exp: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days session lifetime
    });
    const payloadBase64 = Buffer.from(payload).toString("base64");
    const signature = crypto
      .createHmac("sha256", this.jwtSecret)
      .update(payload)
      .digest("hex");

    return `${payloadBase64}.${signature}`;
  }
}
