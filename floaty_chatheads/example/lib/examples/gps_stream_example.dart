import 'dart:async';
import 'dart:math';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'gps_stream/gps_coord.dart';
import 'gps_stream/gps_log_header.dart';
import 'gps_stream/gps_log_list.dart';
import 'gps_stream/gps_position_row.dart';
import 'gps_stream/gps_stream_intro.dart';

part 'gps_stream/gps_simulation.dart';
part 'gps_stream/gps_stream_example_state.dart';

/// Demonstrates [FloatyProxyStream] with a simulated GPS feed.
///
/// The main app generates fake GPS coordinates on a 1-second timer and
/// pushes them to the overlay through a single one-way proxy stream.
final class GpsStreamExample extends StatefulWidget {
  /// Creates the GPS proxy stream example page.
  const factory GpsStreamExample({Key? key}) = GpsStreamExample._;

  const GpsStreamExample._({super.key});

  @override
  State<GpsStreamExample> createState() => _GpsStreamExampleState();
}
