import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'features_showcase/features_overlay_badge_row.dart';
import 'features_showcase/features_overlay_event_log.dart';
import 'features_showcase/features_overlay_header.dart';

part 'features_showcase/features_showcase_overlay_state.dart';

/// Overlay for the features showcase. Displays lifecycle events and
/// lets the user control the badge count from within the overlay.
final class FeaturesShowcaseOverlay extends StatefulWidget {
  /// Creates the features showcase overlay.
  const factory FeaturesShowcaseOverlay({Key? key}) = FeaturesShowcaseOverlay._;

  const FeaturesShowcaseOverlay._({super.key});

  @override
  State<FeaturesShowcaseOverlay> createState() =>
      _FeaturesShowcaseOverlayState();
}
