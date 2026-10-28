import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

/// Shows the purple themed chathead and then sets its badge to 3.
Future<void> launchThemedPurple() async {
  if (!await ensureOverlayPermission()) return;
  const badgeColor = Colors.deepPurple;
  const badgeTextColor = Colors.white;
  const borderColor = Colors.deepPurpleAccent;
  const borderWidth = 2.0;
  const closeTint = Colors.redAccent;
  await FloatyChatheads.showChatHead(
    entryPoint: 'themedOverlayMain',
    assets: const ChatHeadAssets(
      icon: IconSource.asset('assets/showcase_bubble.png'),
      closeIcon: IconSource.asset('assets/showcase_close.png'),
      closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
    ),
    notification: const NotificationConfig(title: 'Themed Chathead'),
    contentWidth: 220,
    contentHeight: 320,
    theme: ChatHeadTheme(
      badgeColor: badgeColor.toARGB32(),
      badgeTextColor: badgeTextColor.toARGB32(),
      bubbleBorderColor: borderColor.toARGB32(),
      bubbleBorderWidth: borderWidth,
      closeTintColor: closeTint.toARGB32(),
      overlayPalette: {
        'primary': Colors.deepPurple.toARGB32(),
        'secondary': Colors.amber.toARGB32(),
        'surface': Colors.white.toARGB32(),
        'background': const Color(0xFFF5F0FF).toARGB32(),
        'onPrimary': Colors.white.toARGB32(),
        'onSecondary': Colors.black.toARGB32(),
        'onSurface': Colors.black87.toARGB32(),
        'error': Colors.red.toARGB32(),
        'onError': Colors.white.toARGB32(),
      },
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 500));
  await FloatyChatheads.updateBadge(3);
}
