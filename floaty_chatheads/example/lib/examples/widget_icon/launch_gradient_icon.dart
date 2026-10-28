import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

/// Shows a chathead whose icon is a gradient container with an icon.
///
/// Returns `false` when the overlay permission was not granted.
Future<bool> launchWidgetIconGradient() async {
  if (!await ensureOverlayPermission()) return false;

  await FloatyChatheads.showChatHead(
    entryPoint: 'widgetIconOverlayMain',
    iconWidget: Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.phone, color: Colors.white, size: 36),
      ),
    ),
    closeIconWidget: const Icon(Icons.cancel, color: Colors.white, size: 32),
    closeBackgroundWidget: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
      ),
    ),
    contentWidth: 200,
    contentHeight: 160,
    notification: const NotificationConfig(title: 'Gradient Icon Active'),
  );
  return true;
}
