import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:sodium/sodium_sumo.dart';
import 'package:stellchat/features/chat/dm_service.dart';
import 'package:stellchat/core/stellar/stellar_wallet_service.dart';
import 'package:stellchat/features/chat/chat_repository.dart';
import 'package:stellchat/features/chat/message.dart';
import 'package:stellchat/features/contacts/contact_service.dart';
import 'package:stellchat/features/contacts/contact.dart';
import 'package:stellchat/core/network/websocket_service.dart';
import 'package:stellchat/core/notification_service.dart';
import 'package:stellchat/features/media/media_manager.dart';
import 'package:stellchat/features/media/media_service.dart';
import 'package:stellchat/core/network/relay_manager.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';

class ManualMockMediaManager implements MediaManager {
  @override
  Future<void> deleteMedia(String mediaId) async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ManualMockNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<void> showNotification({required String title, required String body, String? payload, int? id}) async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ManualMockWebSocketService implements WebSocketService {
  String? lastAckedId;
  @override
  Future<bool> acknowledgeMessage(String messageId) async {
    lastAckedId = messageId;
    return true;
  }
  
  @override
  Future<bool> sendDeliveryReceipt(String messageId) async {
    lastAckedId = messageId;
    return true;
  }
  
  @override
  void onIdentityVerified(Function(dynamic) callback) {}
  @override
  void onMessage(Function(dynamic) callback) {}
  @override
  void onStatusUpdate(Function(dynamic) callback) {}

  @override
  void onInboxMessages(Function(List<dynamic>) callback) {}

  @override
  bool get isConnected => false;
  @override
  bool get isAuthenticated => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ManualMockContactService implements ContactService {
  List<Contact> contacts = [];
  @override
  List<Contact> getAllContacts() => contacts;
  @override
  Contact? getContact(String publicId) => contacts.where((c) => c.publicId == publicId).firstOrNull;
  @override
  bool isBlocked(String publicId) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ManualMockIdentityService {
  final SodiumSumo _sodium;
  dynamic _identity;
  ManualMockIdentityService(this._sodium);

  SodiumSumo get sodium => _sodium;
  dynamic get currentIdentity => _identity;
  void setIdentity(dynamic id) => _identity = id;
  String derivePublicId(Uint8List ed25519PubKey) {
    if (_identity != null && listEquals(ed25519PubKey, _identity!.ed25519KeyPair.publicKey)) {
      return _identity!.publicId;
    }
    return 'id-bob'; // Fallback for test sender
  }
}

class ManualMockMediaService implements MediaService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ManualMockRelayManager implements RelayManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

bool listEquals(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('stellchat_test_hive_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  test('Message Reliability: Replay protection and ACK flow', () async {
    final sodium = await SodiumSumoInit.init();
    final dmService = DMService(sodium);
    final idService = ManualMockIdentityService(sodium);
    
    WalletIdentity deriveIdentity(Uint8List seed, String idSuffix) {
      final ed25519Seed = SecureKey.fromList(sodium, seed);
      final ed25519 = sodium.crypto.sign.seedKeyPair(ed25519Seed);
      final sumo = sodium;
      final x25519Pk = sumo.crypto.sign.pkToCurve25519(ed25519.publicKey);
      final x25519Sk = sumo.crypto.sign.skToCurve25519(ed25519.secretKey);
      final x25519 = KeyPair(publicKey: x25519Pk, secretKey: x25519Sk);

      return WalletIdentity(
        publicId: 'id-$idSuffix',
        ed25519KeyPair: ed25519,
        x25519KeyPair: x25519,
      );
    }

    final aliceSeed = Uint8List.fromList(List.generate(32, (i) => i));
    final bobSeed = Uint8List.fromList(List.generate(32, (i) => i + 10));

    final aliceIdentity = deriveIdentity(aliceSeed, 'alice');
    idService.setIdentity(aliceIdentity);
    
    final bobIdentity = deriveIdentity(bobSeed, 'bob');

    final mockWs = ManualMockWebSocketService();
    final mockContacts = ManualMockContactService();
    final mockNotifications = ManualMockNotificationService();
    final mockMedia = ManualMockMediaManager();
    
    final bobContact = Contact(
      publicId: bobIdentity.publicId,
      alias: 'Bob',
      eid: base64Encode(bobIdentity.ed25519KeyPair.publicKey),
      xid: base64Encode(bobIdentity.x25519KeyPair.publicKey),
      fingerprint: 'fp-bob',
      createdAt: DateTime.now(),
    );
    mockContacts.contacts.add(bobContact);

    final mockMediaService = ManualMockMediaService();
    final mockRelayManager = ManualMockRelayManager();
    final repo = ChatRepository(
      idService, 
      dmService, 
      mockContacts, 
      mockWs, 
      mockNotifications, 
      mockMedia,
      mockMediaService,
      mockRelayManager,
    );
    await repo.init();
    await repo.dangerouslyClearAll();

    // 1. Bob sends to Alice
    final bobToAlicePayload = {
      'type': MessageType.text.name,
      'text': 'Hello Alice, Bob here',
      'sender_eid': base64Encode(bobIdentity.ed25519KeyPair.publicKey),
      'sender_xid': base64Encode(bobIdentity.x25519KeyPair.publicKey),
    };

    final incomingEnvelope = await dmService.encryptDM(
      plaintext: jsonEncode(bobToAlicePayload),
      recipientPublicId: aliceIdentity.publicId,
      recipientXid: aliceIdentity.x25519KeyPair.publicKey,
      senderIdentity: bobIdentity,
    );

    // 2. Process Envelope
    await repo.processEnvelopes([incomingEnvelope.toJson()]);

    final messages = repo.getMessagesForContact(bobIdentity.publicId);
    expect(messages.length, 1);
    expect(messages[0].plaintext, 'Hello Alice, Bob here');
    expect(mockWs.lastAckedId, incomingEnvelope.id);

    // 3. Test Replay Protection
    mockWs.lastAckedId = null;
    await repo.processEnvelopes([incomingEnvelope.toJson()]);
    expect(repo.getMessagesForContact(bobIdentity.publicId).length, 1);
    expect(mockWs.lastAckedId, incomingEnvelope.id); 

    await repo.dangerouslyClearAll();
  });
}
