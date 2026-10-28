/// Minimal quickstart: copy this file into your project to get started.
///
/// This shows the simplest possible integration with floaty_chatheads.
/// For the full example gallery, see `main.dart`.
library;

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'quickstart/quickstart_app.dart';
import 'quickstart/quickstart_overlay.dart';

/// Overlay entry point; runs in a separate Flutter engine.
@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(
      const FloatyScope(child: QuickstartOverlay()),
    );

void main() => runApp(const QuickstartApp());
