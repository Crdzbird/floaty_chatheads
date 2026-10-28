import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

/// Shows the green themed chathead and then sets its badge to 7.
Future<void> launchThemedGreen() async {
  if (!await ensureOverlayPermission()) return;
  await FloatyChatheads.showChatHead(
    entryPoint: 'themedOverlayMain',
    assets: const ChatHeadAssets.defaults(),
    notification: const NotificationConfig(title: 'Green Theme'),
    contentWidth: 220,
    contentHeight: 320,
    theme: ChatHeadTheme(
      badgeColor: Colors.green.toARGB32(),
      badgeTextColor: Colors.white.toARGB32(),
      bubbleBorderColor: Colors.green.shade700.toARGB32(),
      bubbleBorderWidth: 3,
      closeTintColor: Colors.green.shade900.toARGB32(),
      overlayPalette: {
        'primary': Colors.green.toARGB32(),
        'secondary': Colors.lightGreen.toARGB32(),
        'surface': const Color(0xFFF0FFF0).toARGB32(),
        'background': Colors.white.toARGB32(),
        'onPrimary': Colors.white.toARGB32(),
        'onSecondary': Colors.black.toARGB32(),
        'onSurface': Colors.black87.toARGB32(),
        'error': Colors.red.toARGB32(),
        'onError': Colors.white.toARGB32(),
      },
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 500));
  await FloatyChatheads.updateBadge(7);
}
