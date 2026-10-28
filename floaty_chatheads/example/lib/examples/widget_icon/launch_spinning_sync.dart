import 'dart:math';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

/// Shows a chathead whose icon is a sync glyph rotating at 24 fps.
///
/// Returns `false` when the overlay permission was not granted.
Future<bool> launchWidgetIconSpinningSync() async {
  if (!await ensureOverlayPermission()) return false;

  await FloatyChatheads.showChatHead(
    entryPoint: 'widgetIconOverlayMain',
    iconBuilder: (value) => Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.teal,
      ),
      child: Center(
        child: Transform.rotate(
          angle: value * 2 * pi,
          child: const Icon(Icons.sync, color: Colors.white, size: 40),
        ),
      ),
    ),
    animateIcon: true,
    iconAnimationFps: 24,
    iconAnimationDuration: const Duration(seconds: 2),
    closeIconWidget: const Icon(
      Icons.delete_forever,
      color: Colors.white,
      size: 28,
    ),
    closeBackgroundWidget: const DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      child: SizedBox.expand(),
    ),
    contentWidth: 200,
    contentHeight: 160,
    notification: const NotificationConfig(title: 'Animated Icon Active'),
  );
  return true;
}
