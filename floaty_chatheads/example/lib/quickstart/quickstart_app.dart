import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'quickstart_home.dart';

/// The quickstart app: asks for the overlay permission, then shows
/// [QuickstartHome].
final class QuickstartApp extends StatelessWidget {
  /// Creates the quickstart app.
  const factory QuickstartApp({Key? key}) = QuickstartApp._;

  const QuickstartApp._({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FloatyPermissionGate(
        fallback: Center(
          child: ElevatedButton(
            onPressed: () => unawaited(FloatyChatheads.requestPermission()),
            child: const Text('Grant Overlay Permission'),
          ),
        ),
        child: const QuickstartHome(),
      ),
    );
  }
}
