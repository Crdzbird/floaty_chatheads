import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'multi_chathead/multi_chathead_bubble_chips.dart';
import 'multi_chathead/multi_chathead_controls.dart';
import 'multi_chathead/multi_chathead_message_list.dart';
import 'multi_chathead/multi_chathead_status.dart';

part 'multi_chathead/multi_chathead_example_state.dart';

/// Multi-chathead example: add/remove bubbles dynamically.
///
/// Tapping the group expands them into a row (Messenger-style).
/// Each bubble has its own ID and the overlay content switches
/// based on which bubble is active.
final class MultiChatheadExample extends StatefulWidget {
  /// Creates the multi-chathead example page.
  const factory MultiChatheadExample({Key? key}) = MultiChatheadExample._;

  const MultiChatheadExample._({super.key});

  @override
  State<MultiChatheadExample> createState() => _MultiChatheadExampleState();
}
