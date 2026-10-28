import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed/launch_green_theme.dart';
import 'themed/launch_purple_theme.dart';
import 'themed/themed_launch_panel.dart';
import 'themed/themed_responses_header.dart';
import 'themed/themed_responses_list.dart';

part 'themed/themed_example_state.dart';

/// Theming example: custom badge colors, bubble border, close tint,
/// shadow color, and overlay palette delivery.
final class ThemedExample extends StatefulWidget {
  /// Creates the themed example page.
  const factory ThemedExample({Key? key}) = ThemedExample._;

  const ThemedExample._({super.key});

  @override
  State<ThemedExample> createState() => _ThemedExampleState();
}
