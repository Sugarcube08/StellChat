import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sodium/sodium_sumo.dart';
import 'package:stellchat/features/chat/dm_service.dart';
import 'package:stellchat/core/stellar/stellar_wallet_service.dart';

void main() {
  test('Hybrid Encryption (DMService) works', () async {
    final sodium = await SodiumSumoInit.init();
    final dmService = DMService(sodium);
    
    WalletIdentity deriveIdentity(Uint8List seed, String id) {
      final ed25519Seed = SecureKey.fromList(sodium, seed);
      final ed25519 = sodium.crypto.sign.seedKeyPair(ed25519Seed);
      
      final sumo = sodium;
      final x25519Pk = sumo.crypto.sign.pkToCurve25519(ed25519.publicKey);
      final x25519Sk = sumo.crypto.sign.skToCurve25519(ed25519.secretKey);
      final x25519 = KeyPair(publicKey: x25519Pk, secretKey: x25519Sk);

      return WalletIdentity(
        publicId: id,
        ed25519KeyPair: ed25519,
        x25519KeyPair: x25519,
      );
    }

    final aliceSeed = Uint8List.fromList(List.generate(32, (i) => i));
    final bobSeed = Uint8List.fromList(List.generate(32, (i) => i + 10));

    final senderIdentity = deriveIdentity(aliceSeed, 'alice');
    final recipientIdentity = deriveIdentity(bobSeed, 'bob');
    
    const plaintext = 'Hello, this is a hybrid encrypted message!';
    
    // 1. Encrypt
    final envelope = await dmService.encryptDM(
      plaintext: plaintext,
      recipientPublicId: recipientIdentity.publicId,
      recipientXid: recipientIdentity.x25519KeyPair.publicKey,
      senderIdentity: senderIdentity,
    );
    
    expect(envelope.version, 2);
    expect(envelope.encryptedKey, isNotNull);
    
    // 2. Decrypt
    final decrypted = dmService.decryptDM(
      envelope: envelope,
      myPublicId: recipientIdentity.publicId,
      myXidKeyPair: recipientIdentity.x25519KeyPair,
      senderEid: senderIdentity.ed25519KeyPair.publicKey,
    );
    
    expect(decrypted, plaintext);
  });
}
