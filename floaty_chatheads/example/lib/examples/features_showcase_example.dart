import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'features_showcase/features_badge_row.dart';
import 'features_showcase/features_event_log.dart';
import 'features_showcase/features_event_log_header.dart';
import 'features_showcase/features_expand_row.dart';
import 'features_showcase/features_options_panel.dart';
import 'features_showcase/features_section_label.dart';

part 'features_showcase/features_showcase_example_state.dart';
part 'features_showcase/features_showcase_logic.dart';

/// Showcases advanced features: badge count, programmatic expand and
/// collapse, lifecycle events, snap behavior, entrance animations,
/// panel anchor and persistent position.
final class FeaturesShowcaseExample extends StatefulWidget {
  /// Creates the features showcase page.
  const factory FeaturesShowcaseExample({Key? key}) = FeaturesShowcaseExample._;

  const FeaturesShowcaseExample._({super.key});

  @override
  State<FeaturesShowcaseExample> createState() =>
      _FeaturesShowcaseExampleState();
}
