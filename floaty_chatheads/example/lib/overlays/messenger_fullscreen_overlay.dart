import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'messenger_fullscreen/fullscreen_chat_message.dart';
import 'messenger_fullscreen/fullscreen_colors.dart';
import 'messenger_fullscreen/fullscreen_message_list.dart';
import 'messenger_fullscreen/fullscreen_profile_header.dart';
import 'messenger_fullscreen/fullscreen_quick_replies.dart';
import 'messenger_fullscreen/fullscreen_seed_messages.dart';

part 'messenger_fullscreen/messenger_fullscreen_overlay_state.dart';

/// Facebook Messenger-style fullscreen overlay.
///
/// The chathead bubble sits above this panel (rendered by native Android).
/// The content panel fills the full screen; a transparent top spacer reserves
/// room for the bubble row so the chat UI starts just below it.
final class MessengerFullscreenOverlay extends StatefulWidget {
  /// Creates the fullscreen messenger overlay.
  const factory MessengerFullscreenOverlay({Key? key}) =
      MessengerFullscreenOverlay._;

  const MessengerFullscreenOverlay._({super.key});

  @override
  State<MessengerFullscreenOverlay> createState() =>
      _MessengerFullscreenOverlayState();
}
