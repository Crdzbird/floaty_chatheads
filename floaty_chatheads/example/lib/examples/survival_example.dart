import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/survival_actions.dart';
import '../utils.dart';
import 'survival/survival_counter_row.dart';
import 'survival/survival_instructions.dart';
import 'survival/survival_log_header.dart';
import 'survival/survival_log_list.dart';

part 'survival/survival_controls.dart';
part 'survival/survival_example_state.dart';
part 'survival/survival_store.dart';
part 'survival/survival_wiring.dart';

/// Demonstrates overlay survival after app death using [FloatyHostKit]
/// for simplified wiring.
///
/// 1. **Connection state**: the overlay shows a live connected or
///    disconnected banner via `FloatyConnectionState`.
/// 2. **Action queueing**: actions dispatched while disconnected are
///    queued and flushed when the app reconnects.
/// 3. **Proxy fallback**: proxy calls return a fallback value instead
///    of timing out when the main app is unavailable.
final class SurvivalExample extends StatefulWidget {
  /// Creates the survival example page.
  const factory SurvivalExample({Key? key}) = SurvivalExample._;

  const SurvivalExample._({super.key});

  @override
  State<SurvivalExample> createState() => _SurvivalExampleState();
}
