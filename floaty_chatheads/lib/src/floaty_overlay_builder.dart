import 'dart:async';

import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:flutter/widgets.dart';

part 'builders/floaty_overlay_builder_state.dart';

/// Overlay widget that manages the overlay lifecycle for you.
///
/// Calls [FloatyOverlay.setUp], subscribes to the overlay streams with
/// mount checks, and calls [FloatyOverlay.dispose] on unmount:
///
/// ```dart
/// FloatyOverlayBuilder<int>(
///   initialState: 0,
///   onData: (count, data) => data is Map ? data['count'] as int : count,
///   onInit: () => FloatyOverlay.shareData({'action': 'requestState'}),
///   builder: (context, count) => Text('$count'),
/// )
/// ```
///
/// For typed state sync, actions and proxy services use
/// `FloatyOverlayScope` instead.
final class FloatyOverlayBuilder<T> extends StatefulWidget {
  /// Creates a builder starting from [initialState].
  const factory FloatyOverlayBuilder({
    required T initialState,
    required T Function(T current, Object? data) onData,
    required Widget Function(BuildContext context, T state) builder,
    T Function(T current, String id)? onTapped,
    VoidCallback? onInit,
    Key? key,
  }) = FloatyOverlayBuilder<T>._;

  const FloatyOverlayBuilder._({
    required this.initialState,
    required this.onData,
    required this.builder,
    this.onTapped,
    this.onInit,
    super.key,
  });

  /// The state value used before any data arrives.
  final T initialState;

  /// Reducer called whenever [FloatyOverlay.onData] emits. Return the
  /// current value unchanged to ignore the message.
  final T Function(T current, Object? data) onData;

  /// Optional reducer called with the chathead ID when a bubble is tapped.
  final T Function(T current, String id)? onTapped;

  /// Called once after [FloatyOverlay.setUp], before the first build.
  final VoidCallback? onInit;

  /// Builder that receives the current reduced state.
  final Widget Function(BuildContext context, T state) builder;

  @override
  State<FloatyOverlayBuilder<T>> createState() =>
      _FloatyOverlayBuilderState<T>();
}
