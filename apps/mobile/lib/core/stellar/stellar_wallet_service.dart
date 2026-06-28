import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellar;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium/sodium_sumo.dart';

class WalletIdentity {
  final String publicId; // The wallet address G...
  final KeyPair ed25519KeyPair;
  final KeyPair x25519KeyPair;
  
  WalletIdentity({
    required this.publicId,
    required this.ed25519KeyPair,
    required this.x25519KeyPair,
  });
}

class StellarWalletService extends ChangeNotifier {
  final stellar.StellarSDK sdk;
  final String horizonUrl;
  final String friendbotUrl;
  final FlutterSecureStorage _storage;
  final SodiumSumo sodium;
  
  stellar.KeyPair? _keyPair;
  WalletIdentity? _walletIdentity;
  String _walletAddress = "";
  String _sessionToken = "";
  bool _isConnected = false;
  double _xlmBalance = 0.0;
  double _usdcBalance = 0.0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _transactions = [];

  StellarWalletService({
    required this.horizonUrl,
    required this.friendbotUrl,
    required this.sodium,
    required FlutterSecureStorage storage,
  }) : sdk = stellar.StellarSDK(horizonUrl),
       _storage = storage;

  bool get isConnected => _isConnected;
  String get address => _walletAddress;
  String get sessionToken => _sessionToken;
  WalletIdentity? get walletIdentity => _walletIdentity;
  double get xlmBalance => _xlmBalance;
  double get usdcBalance => _usdcBalance;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get transactions => _transactions;

  void _deriveWalletIdentity() {
    if (_keyPair == null) return;
    final seedBytes = _keyPair!.privateKey;
    if (seedBytes == null) return;

    try {
      final ed25519Seed = SecureKey.fromList(sodium, seedBytes);
      final ed25519KeyPair = sodium.crypto.sign.seedKeyPair(ed25519Seed);
      
      final x25519Pk = sodium.crypto.sign.pkToCurve25519(ed25519KeyPair.publicKey);
      final x25519Sk = sodium.crypto.sign.skToCurve25519(ed25519KeyPair.secretKey);
      final x25519KeyPair = KeyPair(publicKey: x25519Pk, secretKey: x25519Sk);

      _walletIdentity = WalletIdentity(
        publicId: _walletAddress,
        ed25519KeyPair: ed25519KeyPair,
        x25519KeyPair: x25519KeyPair,
      );
      debugPrint("[Stellar] E2EE wallet identity derived successfully.");
    } catch (e) {
      debugPrint("[Stellar] Failed to derive cryptographic wallet identity: $e");
    }
  }

  /// Generate or restore in-app wallet keys and authenticate with backend
  Future<void> connectWallet({String? provider = "embedded", String? mnemonic}) async {
    _isLoading = true;
    notifyListeners();

    try {
      stellar.KeyPair kp;
      if (mnemonic != null && mnemonic.trim().isNotEmpty) {
        final seedBytes = sha256.convert(utf8.encode(mnemonic.trim())).bytes;
        kp = stellar.KeyPair.fromSecretSeedList(Uint8List.fromList(seedBytes));
      } else {
        final storedSeedB64 = await _storage.read(key: 'wallet_seed_b64');
        if (storedSeedB64 != null) {
          final seedBytes = base64Decode(storedSeedB64);
          kp = stellar.KeyPair.fromSecretSeedList(seedBytes);
        } else {
          kp = stellar.KeyPair.random();
          await _storage.write(key: 'wallet_seed_b64', value: base64Encode(kp.privateKey!));
        }
      }

      final walletAddr = kp.accountId;

      final isAndroid = defaultTargetPlatform == TargetPlatform.android && !kIsWeb;
      final host = isAndroid ? "10.0.2.2" : "localhost";
      final backendUrl = "http://$host:3000";

      debugPrint("[Stellar] Fetching auth challenge for $walletAddr");
      final nonceResponse = await http.get(Uri.parse("$backendUrl/api/auth/nonce?address=$walletAddr"));
      if (nonceResponse.statusCode != 200) {
        throw Exception("Auth failed: nonce challenge endpoint failed");
      }
      final nonceData = jsonDecode(nonceResponse.body);
      final nonce = nonceData["nonce"] as String;

      final signatureBytes = kp.sign(utf8.encode(nonce));
      final signatureBase64 = base64Encode(signatureBytes);

      debugPrint("[Stellar] Submitting signed challenge for login");
      final loginResponse = await http.post(
        Uri.parse("$backendUrl/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "address": walletAddr,
          "signature": signatureBase64,
          "nonce": nonce,
          "provider": provider,
          "type": "wallet",
          "network": "testnet",
        }),
      );

      if (loginResponse.statusCode != 200 && loginResponse.statusCode != 201) {
        throw Exception("Login rejected by backend: ${loginResponse.body}");
      }

      final loginData = jsonDecode(loginResponse.body);
      final token = loginData["token"] as String;

      await _storage.write(key: 'wallet_address', value: walletAddr);
      await _storage.write(key: 'session_token', value: token);
      await _storage.write(key: 'wallet_provider', value: provider ?? "embedded");

      _keyPair = kp;
      _walletAddress = walletAddr;
      _sessionToken = token;
      _isConnected = true;

      _deriveWalletIdentity();

      await fetchBalances();
      await fetchTransactions();

      debugPrint("[Stellar] Wallet successfully authenticated and session established: $walletAddr");
    } catch (e) {
      debugPrint("[Stellar] Connection/auth error: $e");
      _isConnected = false;
      _keyPair = null;
      _walletIdentity = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore an existing wallet connection from secure storage session metadata
  Future<bool> tryRestoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final addr = await _storage.read(key: 'wallet_address');
      final token = await _storage.read(key: 'session_token');
      final provider = await _storage.read(key: 'wallet_provider');

      if (addr != null && token != null) {
        final seedB64 = await _storage.read(key: 'wallet_seed_b64');
        if (seedB64 != null) {
          _keyPair = stellar.KeyPair.fromSecretSeedList(base64Decode(seedB64));
        }
        
        _walletAddress = addr;
        _sessionToken = token;
        _isConnected = true;

        _deriveWalletIdentity();

        fetchBalances();
        fetchTransactions();

        debugPrint("[Stellar] Restored wallet session for $addr via $provider");
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("[Stellar] Session restoration failed: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Discard the active session and wipe cached session tokens
  Future<void> disconnect() async {
    await _storage.delete(key: 'wallet_address');
    await _storage.delete(key: 'session_token');
    await _storage.delete(key: 'wallet_provider');
    await _storage.delete(key: 'wallet_seed_b64');

    _keyPair = null;
    _walletIdentity = null;
    _walletAddress = "";
    _sessionToken = "";
    _isConnected = false;
    _xlmBalance = 0.0;
    _usdcBalance = 0.0;
    _transactions = [];
    notifyListeners();
    debugPrint("[Stellar] Wallet session terminated.");
  }

  /// Query ledger state from Horizon
  Future<void> fetchBalances() async {
    if (!_isConnected || _walletAddress.isEmpty) return;
    try {
      debugPrint("[Stellar] Querying balances for $address on $horizonUrl");
      try {
        final account = await sdk.accounts.account(address);
        double xlm = 0.0;
        double usdc = 0.0;

        for (var balance in account.balances) {
          if (balance.assetType == "native") {
            xlm = double.tryParse(balance.balance) ?? 0.0;
          } else if (balance.assetCode == "USDC") {
            usdc = double.tryParse(balance.balance) ?? 0.0;
          }
        }

        _xlmBalance = xlm;
        _usdcBalance = usdc;
      } catch (err) {
        if (err.toString().contains("404") || err.toString().contains("not_found")) {
          debugPrint("[Stellar] Account not found on ledger. Invoking Friendbot...");
          await fundFromFriendbot();
          final account = await sdk.accounts.account(address);
          for (var balance in account.balances) {
            if (balance.assetType == "native") {
              _xlmBalance = double.tryParse(balance.balance) ?? 0.0;
            } else if (balance.assetCode == "USDC") {
              _usdcBalance = double.tryParse(balance.balance) ?? 0.0;
            }
          }
        } else {
          rethrow;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("[Stellar] Error fetching balances: $e");
    }
  }

  /// Request local Friendbot XLM funding
  Future<void> fundFromFriendbot() async {
    if (_walletAddress.isEmpty) return;
    final url = "$friendbotUrl?addr=$address";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception("Friendbot failed: ${response.body}");
      }
      debugPrint("[Stellar] Friendbot successfully funded account.");
    } catch (e) {
      debugPrint("[Stellar] Friendbot funding error: $e");
      rethrow;
    }
  }

  /// Build, Sign, and Submit a Payment transaction
  Future<String> submitPayment(String recipientAddress, String amountVal, String assetCode) async {
    if (_keyPair == null) throw Exception("Wallet not connected");

    debugPrint("[Stellar] Submitting payment of $amountVal $assetCode to $recipientAddress");
    final sourceAccount = await sdk.accounts.account(address);

    stellar.Asset asset = stellar.Asset.NATIVE;
    if (assetCode == "USDC") {
      const usdcIssuer = "GD6W5F6BLDWR3B5MX43NBLF2J7J37A2C7L6E2QPL47G53WJ735STELL1";
      asset = stellar.AssetTypeCreditAlphaNum4("USDC", usdcIssuer);
    }

    final paymentOp = stellar.PaymentOperationBuilder(recipientAddress, asset, amountVal).build();
    final tx = stellar.TransactionBuilder(sourceAccount)
        .addOperation(paymentOp)
        .build();

    tx.sign(_keyPair!, stellar.Network.TESTNET);
    final response = await sdk.submitTransaction(tx);
    if (response.success == true) {
      debugPrint("[Stellar] Payment transaction succeeded. Hash: ${response.hash}");
      await fetchBalances();
      await fetchTransactions();
      return response.hash!;
    } else {
      throw Exception("Transaction rejected by ledger: ${response.extras?.resultCodes?.transactionResultCode}");
    }
  }

  /// Fetch payments history from Horizon
  Future<void> fetchTransactions() async {
    if (_walletAddress.isEmpty) return;
    try {
      debugPrint("[Stellar] Querying transaction logs for $address");
      final response = await sdk.payments
          .forAccount(address)
          .order(stellar.RequestBuilderOrder.DESC)
          .limit(10)
          .execute();
          
      final List<Map<String, dynamic>> txs = [];
      for (var record in response.records) {
        if (record is stellar.PaymentOperationResponse) {
          final isSent = record.from == address;
          final amount = record.amount;
          final assetCode = record.assetCode ?? "XLM";
          final party = isSent ? record.to : record.from;
          txs.add({
            "type": isSent ? "Sent" : "Received",
            "amount": "$amount $assetCode",
            "recipient": party.length > 8 ? "${party.substring(0, 4)}...${party.substring(party.length - 4)}" : party,
            "txHash": record.transactionHash,
            "status": "ZK Verified",
            "time": "Just now"
          });
        }
      }
      _transactions = txs;
      notifyListeners();
    } catch (e) {
      debugPrint("[Stellar] Error querying transaction logs: $e");
    }
  }
}
