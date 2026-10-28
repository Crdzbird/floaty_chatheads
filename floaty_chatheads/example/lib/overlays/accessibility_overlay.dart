import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'accessibility/accessibility_overlay_close_button.dart';
import 'accessibility/accessibility_overlay_frame.dart';
import 'accessibility/accessibility_overlay_last_message.dart';
import 'accessibility/accessibility_overlay_tap_button.dart';

part 'accessibility/accessibility_overlay_state.dart';

/// Simple overlay for accessibility testing with TalkBack.
///
/// Uses semantic labels and large touch targets for screen-reader
/// friendliness.
final class AccessibilityOverlay extends StatefulWidget {
  /// Creates the accessibility test overlay.
  const factory AccessibilityOverlay({Key? key}) = AccessibilityOverlay._;

  const AccessibilityOverlay._({super.key});

  @override
  State<AccessibilityOverlay> createState() => _AccessibilityOverlayState();
}
