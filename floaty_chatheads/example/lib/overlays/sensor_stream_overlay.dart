import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../examples/sensor_stream/accel_data.dart';
import '../examples/sensor_stream/light_data.dart';
import 'sensor_stream/sensor_overlay_accel_section.dart';
import 'sensor_stream/sensor_overlay_footer.dart';
import 'sensor_stream/sensor_overlay_header.dart';
import 'sensor_stream/sensor_overlay_light_section.dart';

part 'sensor_stream/sensor_stream_overlay_state.dart';

/// Overlay that subscribes to two independent [FloatyProxyStream]
/// instances, accelerometer (`accel`) and light sensor (`light`), and
/// renders both feeds as compact visual indicators.
final class SensorStreamOverlay extends StatefulWidget {
  /// Creates the sensor monitor overlay.
  const factory SensorStreamOverlay({Key? key}) = SensorStreamOverlay._;

  const SensorStreamOverlay._({super.key});

  @override
  State<SensorStreamOverlay> createState() => _SensorStreamOverlayState();
}
