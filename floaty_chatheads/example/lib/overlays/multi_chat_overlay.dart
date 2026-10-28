import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'multi_chat/multi_chat_card_body.dart';

part 'multi_chat/multi_chat_overlay_state.dart';

/// Overlay for the multi-chathead example.
///
/// Switches content based on which chathead bubble is active.
/// Each bubble ID maps to a different color and greeting.
final class MultiChatOverlay extends StatefulWidget {
  /// Creates the multi-chat overlay.
  const factory MultiChatOverlay({Key? key}) = MultiChatOverlay._;

  const MultiChatOverlay._({super.key});

  @override
  State<MultiChatOverlay> createState() => _MultiChatOverlayState();
}
