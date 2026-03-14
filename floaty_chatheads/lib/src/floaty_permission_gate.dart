import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_permission_gate}
/// A widget that checks for overlay permission before showing its [child].
///
/// If the permission is not granted, it displays [fallback] (which typically
/// contains a button to request it). Once the permission is granted,
/// it automatically swaps to [child].
///
/// On iOS this gate always shows [child] immediately since no special
/// permission is required.
///
/// ```dart
/// FloatyPermissionGate(
///   child: MyMainContent(),
///   fallback: Center(
///     child: ElevatedButton(
///       onPressed: () => FloatyChatheads.requestPermission(),
///       child: Text('Grant Overlay Permission'),
///     ),
///   ),
/// )
/// ```
/// {@endtemplate}
final class FloatyPermissionGate extends StatefulWidget {
  /// {@macro floaty_permission_gate}
  const FloatyPermissionGate({
    required this.child,
    required this.fallback,
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.checkInterval = const Duration(seconds: 1),
  });

  /// {@template floaty_permission_gate.child}
  /// Widget shown when overlay permission **is** granted.
  /// {@endtemplate}
  final Widget child;

  /// {@template floaty_permission_gate.fallback}
  /// Widget shown when overlay permission is **not** granted.
  ///
  /// Typically contains a button that calls
  /// [FloatyChatheads.requestPermission].
  /// {@endtemplate}
  final Widget fallback;

  /// {@template floaty_permission_gate.on_permission_granted}
  /// Called once when permission is first detected as granted.
  /// {@endtemplate}
  final VoidCallback? onPermissionGranted;

  /// {@template floaty_permission_gate.on_permission_denied}
  /// Called when permission is checked and found not granted.
  /// {@endtemplate}
  final VoidCallback? onPermissionDenied;

  /// {@template floaty_permission_gate.check_interval}
  /// How often to re-check permission while displaying [fallback].
  ///
  /// Defaults to 1 second. The timer stops once permission is granted.
  /// {@endtemplate}
  final Duration checkInterval;

  @override
  State<FloatyPermissionGate> createState() => _FloatyPermissionGateState();
}

final class _FloatyPermissionGateState extends State<FloatyPermissionGate>
    with WidgetsBindingObserver {
  bool _granted = false;
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check when the app resumes (user might have just toggled the setting).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_granted) {
      unawaited(_checkPermission());
    }
  }

  Future<void> _checkPermission() async {
    final granted = await FloatyChatheads.checkPermission();
    if (!mounted) return;

    setState(() {
      _granted = granted;
      _loading = false;
    });

    if (granted) {
      _pollTimer?.cancel();
      widget.onPermissionGranted?.call();
    } else {
      widget.onPermissionDenied?.call();
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(widget.checkInterval, (_) {
      if (_granted) {
        _pollTimer?.cancel();
        return;
      }
      unawaited(_checkPermission());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    return _granted ? widget.child : widget.fallback;
  }
}
