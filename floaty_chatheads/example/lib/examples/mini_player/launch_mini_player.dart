import 'package:floaty_chatheads/floaty_chatheads.dart';

import '../../utils.dart';

/// Shows the mini player chathead after making sure the overlay
/// permission is granted.
Future<void> launchMiniPlayer() async {
  if (!await ensureOverlayPermission()) return;
  await FloatyChatheads.showChatHead(
    entryPoint: 'miniPlayerOverlayMain',
    assets: const ChatHeadAssets(
      icon: IconSource.asset('assets/showcase_bubble.png'),
      closeIcon: IconSource.asset('assets/close.png'),
      closeBackground: IconSource.asset('assets/closeBg.png'),
    ),
    notification: const NotificationConfig(title: 'Mini Player Active'),
    contentWidth: 260,
    contentHeight: 160,
  );
}
