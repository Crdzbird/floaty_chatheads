import 'dart:async';
import 'dart:math';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'sensor_stream/accel_data.dart';
import 'sensor_stream/light_data.dart';
import 'sensor_stream/sensor_accel_card.dart';
import 'sensor_stream/sensor_light_card.dart';
import 'sensor_stream/sensor_status_row.dart';
import 'sensor_stream/sensor_stream_intro.dart';

part 'sensor_stream/sensor_simulation.dart';
part 'sensor_stream/sensor_stream_example_state.dart';

/// Demonstrates multiple [FloatyProxyStream] instances running in
/// parallel, one for accelerometer data and one for light sensor data.
///
/// The main app simulates both feeds on a timer and pushes them
/// independently; the overlay subscribes to both streams.
final class SensorStreamExample extends StatefulWidget {
  /// Creates the sensor proxy streams example page.
  const factory SensorStreamExample({Key? key}) = SensorStreamExample._;

  const SensorStreamExample._({super.key});

  @override
  State<SensorStreamExample> createState() => _SensorStreamExampleState();
}
