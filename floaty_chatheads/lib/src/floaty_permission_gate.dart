import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';

part 'gate/floaty_permission_gate_state.dart';

/// A widget that checks for overlay permission before showing its
/// [child].
///
/// While the permission is missing it shows [fallback] (typically a
/// button calling [FloatyChatheads.requestPermission]) and re-checks
/// every [checkInterval] and on app resume, swapping to [child] once
/// granted. On iOS no permission is needed, so [child] shows right away.
final class FloatyPermissionGate extends StatefulWidget {
  /// Creates a gate around [child] with [fallback] while not granted.
  const factory FloatyPermissionGate({
    required Widget child,
    required Widget fallback,
    Key? key,
    VoidCallback? onPermissionGranted,
    VoidCallback? onPermissionDenied,
    Duration checkInterval,
  }) = FloatyPermissionGate._;

  const FloatyPermissionGate._({
    required this.child,
    required this.fallback,
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.checkInterval = const Duration(seconds: 1),
  });

  /// Widget shown when overlay permission is granted.
  final Widget child;

  /// Widget shown when overlay permission is not granted.
  final Widget fallback;

  /// Called once when permission is first detected as granted.
  final VoidCallback? onPermissionGranted;

  /// Called when permission is checked and found not granted.
  final VoidCallback? onPermissionDenied;

  /// How often to re-check permission while showing [fallback]. Defaults
  /// to 1 second; polling stops once permission is granted.
  final Duration checkInterval;

  @override
  State<FloatyPermissionGate> createState() => _FloatyPermissionGateState();
}
