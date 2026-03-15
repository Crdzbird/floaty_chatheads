import 'dart:async';

import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_overlay_builder}
/// Zero-boilerplate overlay widget that manages the full overlay lifecycle.
///
/// Handles [FloatyOverlay.setUp], stream subscriptions, mount-checking,
/// and [FloatyOverlay.dispose] automatically — turning overlay widgets
/// into stateless declarations:
///
/// ```dart
/// class CounterOverlay extends StatelessWidget {
///   const CounterOverlay({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return FloatyOverlayBuilder<int>(
///       initialState: 0,
///       onData: (count, data) =>
///           data is Map && data['count'] is int
///               ? data['count'] as int
///               : count,
///       onInit: () => FloatyOverlay.shareData({'action': 'requestState'}),
///       builder: (context, count) => Text('$count'),
///     );
///   }
/// }
/// ```
///
/// For overlays that need typed state sync, action routing, and proxy
/// services, use `FloatyOverlayScope` instead.
/// {@endtemplate}
final class FloatyOverlayBuilder<T> extends StatefulWidget {
  /// {@macro floaty_overlay_builder}
  const FloatyOverlayBuilder({
    required this.initialState,
    required this.onData,
    required this.builder,
    this.onTapped,
    this.onInit,
    super.key,
  });

  /// The state value used before any data arrives.
  final T initialState;

  /// Reducer called whenever [FloatyOverlay.onData] emits.
  ///
  /// Receives the current state and raw incoming data, and returns the
  /// new state. Return the current value unchanged to ignore the message.
  final T Function(T current, Object? data) onData;

  /// Optional reducer called when a chathead bubble is tapped.
  ///
  /// Receives the current state and the chathead ID.
  final T Function(T current, String id)? onTapped;

  /// Called once after [FloatyOverlay.setUp], before the first build.
  ///
  /// Use this to send initial requests to the main app:
  /// ```dart
  /// onInit: () => FloatyOverlay.shareData({'action': 'requestState'}),
  /// ```
  final VoidCallback? onInit;

  /// Builder that receives the current reduced state.
  final Widget Function(BuildContext context, T state) builder;

  @override
  State<FloatyOverlayBuilder<T>> createState() =>
      _FloatyOverlayBuilderState<T>();
}

class _FloatyOverlayBuilderState<T> extends State<FloatyOverlayBuilder<T>> {
  late T _state;
  final _subs = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _state = widget.initialState;

    _subs.add(
      FloatyOverlay.onData.listen((data) {
        if (!mounted) return;
        setState(() => _state = widget.onData(_state, data));
      }),
    );

    if (widget.onTapped != null) {
      _subs.add(
        FloatyOverlay.onTapped.listen((id) {
          if (!mounted) return;
          setState(() => _state = widget.onTapped!(_state, id));
        }),
      );
    }

    widget.onInit?.call();
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    FloatyOverlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _state);
}
