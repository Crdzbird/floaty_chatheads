import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'dashboard/dashboard_info_banner.dart';
import 'dashboard/dashboard_log_header.dart';
import 'dashboard/dashboard_log_list.dart';
import 'dashboard/dashboard_note_form.dart';

part 'dashboard/dashboard_example_logic.dart';
part 'dashboard/dashboard_example_state.dart';

/// Demonstrates a near-fullscreen, scrollable overlay.
///
/// The overlay shows a notes dashboard that covers most of the screen.
/// The main app can push notes into the overlay via
/// [FloatyChatheads.shareData].
final class DashboardExample extends StatefulWidget {
  /// Creates the dashboard example page.
  const factory DashboardExample({Key? key}) = DashboardExample._;

  const DashboardExample._({super.key});

  @override
  State<DashboardExample> createState() => _DashboardExampleState();
}
