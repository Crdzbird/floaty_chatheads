import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

part 'quickstart_home_state.dart';

/// The quickstart home screen: launches the chathead with one call and
/// shows the latest status.
final class QuickstartHome extends StatefulWidget {
  /// Creates the quickstart home screen.
  const factory QuickstartHome({Key? key}) = QuickstartHome._;

  const QuickstartHome._({super.key});

  @override
  State<QuickstartHome> createState() => _QuickstartHomeState();
}
