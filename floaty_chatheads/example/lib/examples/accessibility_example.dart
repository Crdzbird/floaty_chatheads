import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'accessibility/accessibility_controls.dart';
import 'accessibility/accessibility_event_log.dart';
import 'accessibility/accessibility_guide_card.dart';

part 'accessibility/accessibility_example_state.dart';

/// Accessibility example: demonstrates TalkBack support.
///
/// Instructions for testing with TalkBack are shown on-screen. The overlay
/// uses large touch targets and semantic labels.
final class AccessibilityExample extends StatefulWidget {
  /// Creates the accessibility example page.
  const factory AccessibilityExample({Key? key}) = AccessibilityExample._;

  const AccessibilityExample._({super.key});

  @override
  State<AccessibilityExample> createState() => _AccessibilityExampleState();
}
