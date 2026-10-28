import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'auto_launch/auto_launch_instructions.dart';
import 'auto_launch/auto_launch_switches.dart';

part 'auto_launch/auto_launch_example_state.dart';

/// Demonstrates [ChatHeadConfig.autoLaunchOnBackground] and
/// [ChatHeadConfig.persistOnAppClose].
///
/// With `autoLaunchOnBackground` the chathead appears when the app moves to
/// the background and is dismissed when the app returns to the foreground.
/// With `persistOnAppClose` the overlay service survives after the main app
/// process is killed; without it the service stops when the app disconnects.
final class AutoLaunchExample extends StatefulWidget {
  /// Creates the auto-launch example page.
  const factory AutoLaunchExample({Key? key}) = AutoLaunchExample._;

  const AutoLaunchExample._({super.key});

  @override
  State<AutoLaunchExample> createState() => _AutoLaunchExampleState();
}
