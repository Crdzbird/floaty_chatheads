import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'messenger/messenger_app_bar_action.dart';
import 'messenger/messenger_auto_scroll.dart';
import 'messenger/messenger_hint_banner.dart';
import 'messenger/messenger_input_bar.dart';
import 'messenger/messenger_message.dart';
import 'messenger/messenger_message_list.dart';

part 'messenger/messenger_example_state.dart';

/// Messenger-style chat: main app has a text input, overlay shows
/// quick-reply buttons. Both sides display all messages.
final class MessengerExample extends StatefulWidget {
  /// Creates the messenger example page.
  const factory MessengerExample({Key? key}) = MessengerExample._;

  const MessengerExample._({super.key});

  @override
  State<MessengerExample> createState() => _MessengerExampleState();
}
