import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers.dart';

mixin IdentityActions {
  Future<void> shareIdentity(WidgetRef ref) async {
    final relayManager = ref.read(relayManagerProvider);
    final relays = await relayManager.getRelays();
    final pkg = await ref.read(identityServiceProvider).createPackage(relays);
    final encodedPkg = pkg.toEncodedString();
    
    final customLink = 'stellchat://identity/$encodedPkg';
    final webLink = 'https://stellchat.app/i/$encodedPkg';
    
    await SharePlus.instance.share(ShareParams(
      text: 'Connect with me on StellChat!\n\nApp Link: $customLink\nWeb Link: $webLink',
      subject: 'StellChat Identity',
    ));
  }
}
