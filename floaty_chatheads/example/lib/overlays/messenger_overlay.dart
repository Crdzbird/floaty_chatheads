import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../examples/messenger/messenger_auto_scroll.dart';
import '../examples/messenger/messenger_message.dart';
import 'messenger/messenger_overlay_header.dart';
import 'messenger/messenger_overlay_message_list.dart';
import 'messenger/messenger_quick_replies.dart';

part 'messenger/messenger_overlay_state.dart';

/// Compact messenger overlay with quick-reply chips and message display.
///
/// Uses tap-to-send buttons instead of TextField (text input inside
/// Android overlays is unreliable).
final class MessengerOverlay extends StatefulWidget {
  /// Creates the messenger overlay.
  const factory MessengerOverlay({Key? key}) = MessengerOverlay._;

  const MessengerOverlay._({super.key});

  @override
  State<MessengerOverlay> createState() => _MessengerOverlayState();
}
