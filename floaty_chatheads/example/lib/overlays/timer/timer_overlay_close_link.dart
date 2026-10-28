import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Small grey "Close" text that closes the stopwatch overlay.
final class TimerOverlayCloseLink extends StatelessWidget {
  /// Creates the close link.
  const factory TimerOverlayCloseLink({Key? key}) = TimerOverlayCloseLink._;

  const TimerOverlayCloseLink._({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unawaited(FloatyOverlay.closeOverlay()),
      child: Text(
        'Close',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 10,
        ),
      ),
    );
  }
}
