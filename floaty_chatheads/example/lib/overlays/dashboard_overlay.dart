import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'dashboard/dashboard_colors.dart';
import 'dashboard/dashboard_header.dart';
import 'dashboard/dashboard_note.dart';
import 'dashboard/dashboard_notes_list.dart';
import 'dashboard/dashboard_seed_notes.dart';
import 'dashboard/dashboard_stats_row.dart';

part 'dashboard/dashboard_overlay_state.dart';

/// Near-fullscreen scrollable overlay that displays a notes dashboard.
///
/// Uses a fully opaque dark background so no app content bleeds through.
/// Demonstrates rich scrollable content in an overlay panel.
final class DashboardOverlay extends StatefulWidget {
  /// Creates the dashboard overlay.
  const factory DashboardOverlay({Key? key}) = DashboardOverlay._;

  const DashboardOverlay._({super.key});

  @override
  State<DashboardOverlay> createState() => _DashboardOverlayState();
}
