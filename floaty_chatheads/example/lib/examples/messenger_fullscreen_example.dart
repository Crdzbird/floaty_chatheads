import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'dashboard/dashboard_info_banner.dart';
import 'dashboard/dashboard_log_header.dart';
import 'dashboard/dashboard_log_list.dart';
import 'messenger_fullscreen/messenger_fullscreen_composer.dart';

part 'messenger_fullscreen/messenger_fullscreen_example_logic.dart';
part 'messenger_fullscreen/messenger_fullscreen_example_state.dart';

/// Facebook Messenger-style chathead: tap the bubble and the whole
/// screen below it becomes a full chat conversation panel.
final class MessengerFullscreenExample extends StatefulWidget {
  /// Creates the fullscreen messenger example page.
  const factory MessengerFullscreenExample({Key? key}) =
      MessengerFullscreenExample._;

  const MessengerFullscreenExample._({super.key});

  @override
  State<MessengerFullscreenExample> createState() =>
      _MessengerFullscreenExampleState();
}
