import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

/// Shows a chathead with a widget-based close target and ring background.
///
/// Returns `false` when the overlay permission was not granted.
Future<bool> launchWidgetIconCustomClose() async {
  if (!await ensureOverlayPermission()) return false;

  await FloatyChatheads.showChatHead(
    entryPoint: 'widgetIconOverlayMain',
    iconWidget: Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueGrey,
      ),
      child: const Center(
        child: Icon(Icons.chat, color: Colors.white, size: 36),
      ),
    ),
    closeIconWidget: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.delete_outline, color: Colors.white, size: 32),
      ),
    ),
    closeBackgroundWidget: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
        color: Colors.black26,
      ),
    ),
    contentWidth: 200,
    contentHeight: 160,
    notification: const NotificationConfig(title: 'Custom Close Active'),
  );
  return true;
}
