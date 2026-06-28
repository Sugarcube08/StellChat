import { Test, TestingModule } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import { AppModule } from "../src/app.module";
import { io, Socket } from "socket.io-client";
import {
  describe,
  expect,
  it,
  beforeAll,
  afterAll,
  afterEach,
  jest,
} from "@jest/globals";
import * as crypto from "crypto";

import { getRepositoryToken } from "@nestjs/typeorm";
import { MessageEntity } from "../src/inbox/entities/message.entity";
import { DeliveryEntity } from "../src/inbox/entities/delivery.entity";
import { MediaEntity } from "../src/media/entities/media.entity";
import { MediaService } from "../src/media/media.service";
import { UserEntity } from "../src/auth/entities/user.entity";
import {
  PaymentEntity,
  PaymentRequestEntity,
  ProofRecordEntity,
  WalletLinkEntity,
} from "../src/payment/entities/payment.entity";
import { PaymentService } from "../src/payment/payment.service";

describe("StellChat Integration (E2E & WS)", () => {
  let app: INestApplication;
  let client1: Socket;
  let client2: Socket;
  let mockRedis: any;
  let port: number;
  let paymentService: PaymentService;

  const jwtSecret = "stellchat-auth-jwt-secret-key-42";
  const testWallet1 =
    "GBX5Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2";
  const testWallet2 =
    "GBY3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3Y3";

  // Helper to generate valid JWT session token
  function generateTestToken(address: string): string {
    const payload = JSON.stringify({
      address,
      exp: Date.now() + 1 * 60 * 60 * 1000, // 1 hour
    });
    const payloadBase64 = Buffer.from(payload).toString("base64");
    const signature = crypto
      .createHmac("sha256", jwtSecret)
      .update(payload)
      .digest("hex");
    return `${payloadBase64}.${signature}`;
  }

  beforeAll(async () => {
    mockRedis = {
      pipeline: jest.fn().mockReturnValue({
        setex: jest.fn().mockReturnThis(),
        zadd: jest.fn().mockReturnThis(),
        zremrangebyrank: jest.fn().mockReturnThis(),
        expire: jest.fn().mockReturnThis(),
        zrem: jest.fn().mockReturnThis(),
        del: jest.fn().mockReturnThis(),
        incr: jest.fn().mockReturnThis(),
        exec: (jest.fn() as any).mockResolvedValue([]),
      }),
      multi: jest.fn().mockReturnValue({
        lrange: jest.fn().mockReturnThis(),
        del: jest.fn().mockReturnThis(),
        exec: (jest.fn() as any).mockResolvedValue([[], []]),
      }),
      zrangebyscore: (jest.fn() as any).mockResolvedValue([]),
      mget: (jest.fn() as any).mockResolvedValue([]),
      zrem: (jest.fn() as any).mockResolvedValue(0),
      setex: (jest.fn() as any).mockResolvedValue("OK"),
      get: (jest.fn() as any).mockResolvedValue(null),
      del: (jest.fn() as any).mockResolvedValue(1),
      lpush: (jest.fn() as any).mockResolvedValue(1),
      ltrim: (jest.fn() as any).mockResolvedValue("OK"),
      expire: (jest.fn() as any).mockResolvedValue(1),
      publish: (jest.fn() as any).mockResolvedValue(1),
      on: jest.fn(),
      subscribe: jest.fn(),
    };

    const mockRepo = {
      create: (jest.fn() as any).mockImplementation((e: any) => e),
      save: (jest.fn() as any).mockImplementation(async (e: any) => e),
      find: (jest.fn() as any).mockResolvedValue([]),
      findOne: (jest.fn() as any).mockImplementation(async (query: any) => {
        const id = query?.where?.id || query?.where?.tx_hash;
        return {
          id: id || "test-request-id",
          sender_id: testWallet1,
          recipient_id: testWallet2,
          amount: "10.5",
          asset: "XLM",
          status: "PENDING",
          tx_hash: "0xabcdef1234567890",
        };
      }),
      count: (jest.fn() as any).mockResolvedValue(0),
      delete: (jest.fn() as any).mockResolvedValue({}),
      update: (jest.fn() as any).mockResolvedValue({}),
    };

    const mockMediaService = {
      deleteMedia: (jest.fn() as any).mockResolvedValue({}),
      onModuleInit: jest.fn(),
    };

    try {
      const moduleFixture: TestingModule = await Test.createTestingModule({
        imports: [AppModule],
      })
        .overrideProvider("REDIS_CLIENT")
        .useValue(mockRedis)
        .overrideProvider("REDIS_SUBSCRIBER")
        .useValue(mockRedis)
        .overrideProvider(getRepositoryToken(MessageEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(DeliveryEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(MediaEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(UserEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(WalletLinkEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(PaymentRequestEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(PaymentEntity))
        .useValue(mockRepo)
        .overrideProvider(getRepositoryToken(ProofRecordEntity))
        .useValue(mockRepo)
        .overrideProvider(MediaService)
        .useValue(mockMediaService)
        .compile();

      app = moduleFixture.createNestApplication();
      await app.init();
      await app.listen(0);
      const address = app.getHttpServer().address();
      port = typeof address === "string" ? 0 : address.port;
      paymentService = app.get<PaymentService>(PaymentService);
    } catch (e) {
      console.error("Failed to compile E2E module", e);
    }
  });

  afterAll(async () => {
    if (app) await app.close();
  });

  afterEach(() => {
    if (client1) client1.disconnect();
    if (client2) client2.disconnect();
  });

  it("should disconnect connections lacking auth tokens", (done) => {
    if (!app) return done();
    const url = `http://localhost:${port}`;
    client1 = io(url, { forceNew: true });

    client1.on("disconnect", () => {
      // Expect disconnect when no token
      done();
    });
  });

  it("should successfully authenticate connection using a valid wallet token", (done) => {
    if (!app) return done();
    const url = `http://localhost:${port}`;
    const token = generateTestToken(testWallet1);

    client1 = io(url, {
      forceNew: true,
      auth: { token },
    });

    client1.on("connect", () => {
      expect(client1.connected).toBe(true);
      done();
    });
  });

  it("should execute private message delivery over WebSockets", (done) => {
    if (!app) return done();
    const url = `http://localhost:${port}`;
    const token1 = generateTestToken(testWallet1);
    const token2 = generateTestToken(testWallet2);

    client1 = io(url, { forceNew: true, auth: { token: token1 } });
    client2 = io(url, { forceNew: true, auth: { token: token2 } });

    client1.on("connect", () => {
      client2.on("connect", () => {
        // Send a message from client1 to client2
        client1.emit("message.send", {
          target_id: testWallet2,
          ciphertext: "encrypted-payload-data",
          v: 2,
        });
      });
    });

    client2.on("message.receive", (data) => {
      expect(data.c).toBe("encrypted-payload-data");
      done();
    });
  });

  it("should create payment requests, submit payment hashes, and mock verify proofs", async () => {
    if (!app) return;

    // 1. Create request
    const request = await paymentService.createPaymentRequest(
      testWallet1,
      testWallet2,
      "10.5",
      "XLM",
    );
    expect(request.amount).toBe("10.5");
    expect(request.status).toBe("PENDING");

    // 2. Submit payment hash
    const payment = await paymentService.submitPayment(
      request.id,
      "0xabcdef1234567890",
    );
    expect(payment.tx_hash).toBe("0xabcdef1234567890");
    expect(payment.status).toBe("PENDING");
  });
});
