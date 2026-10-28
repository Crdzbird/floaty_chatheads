import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'notification_counter/counter_badge.dart';

/// Badge overlay that displays a notification count.
///
/// Receives the count from the main app and can send a 'clear' action back.
/// Uses [FloatyOverlayBuilder] for the overlay lifecycle.
final class NotificationCounterOverlay extends StatelessWidget {
  /// Creates the notification counter overlay.
  const factory NotificationCounterOverlay({Key? key}) =
      NotificationCounterOverlay._;

  const NotificationCounterOverlay._({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayBuilder<int>(
      initialState: 0,
      onData: (count, data) =>
          data is Map && data['count'] is int ? data['count'] as int : count,
      onInit: () =>
          unawaited(FloatyOverlay.shareData({'action': 'requestState'})),
      builder: (context, count) => CounterBadge(count: count),
    );
  }
}
