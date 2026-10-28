import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

/// Shows a chathead whose icon is a static text avatar widget.
///
/// Returns `false` when the overlay permission was not granted.
Future<bool> launchWidgetIconTextAvatar() async {
  if (!await ensureOverlayPermission()) return false;

  await FloatyChatheads.showChatHead(
    entryPoint: 'widgetIconOverlayMain',
    iconWidget: const CircleAvatar(
      backgroundColor: Colors.indigo,
      child: Text(
        'JD',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    closeIconWidget: const Icon(Icons.close, color: Colors.white, size: 28),
    closeBackgroundWidget: const DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      child: SizedBox.expand(),
    ),
    contentWidth: 200,
    contentHeight: 160,
    notification: const NotificationConfig(title: 'Widget Icon Active'),
  );
  return true;
}
