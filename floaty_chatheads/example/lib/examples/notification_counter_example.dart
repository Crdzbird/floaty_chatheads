import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'notification_counter/counter_controls.dart';
import 'notification_counter/counter_display.dart';

part 'notification_counter/notification_counter_example_state.dart';

/// Counter badge example: the main app changes a counter and the overlay
/// shows it as a badge. The overlay can send 'clear' back to reset it.
final class NotificationCounterExample extends StatefulWidget {
  /// Creates the notification counter example page.
  const factory NotificationCounterExample({Key? key}) =
      NotificationCounterExample._;

  const NotificationCounterExample._({super.key});

  @override
  State<NotificationCounterExample> createState() =>
      _NotificationCounterExampleState();
}
