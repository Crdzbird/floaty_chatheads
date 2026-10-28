import 'dart:async';

import 'package:floaty_chatheads/src/floaty_action_router.dart';
import 'package:floaty_chatheads/src/floaty_kit.dart';
import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:floaty_chatheads/src/overlay_scope/floaty_overlay_scope_builder.dart';
import 'package:flutter/widgets.dart';

part 'overlay_scope/floaty_overlay_scope_inherited.dart';
part 'overlay_scope/floaty_overlay_scope_state.dart';

/// A reactive scope that owns a [FloatyOverlayKit] and rebuilds [builder]
/// on every state or connection change:
///
/// ```dart
/// FloatyOverlayScope<MyState>(
///   stateToJson: (s) => s.toJson(),
///   stateFromJson: MyState.fromJson,
///   initialState: MyState(),
///   builder: (context, kit, state, connected) =>
///       Text(connected ? 'Counter: ${state.counter}' : 'Offline'),
/// )
/// ```
///
/// The scope calls [FloatyOverlay.setUp], and on unmount disposes the
/// kit, its subscriptions and [FloatyOverlay]. Descendants reach the kit
/// through [FloatyOverlayScope.of].
final class FloatyOverlayScope<S> extends StatefulWidget {
  /// Creates a scope starting from [initialState].
  const factory FloatyOverlayScope({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    required FloatyOverlayScopeBuilder<S, bool> builder,
    int maxQueueSize,
    QueueOverflowStrategy overflowStrategy,
    Duration proxyTimeout,
    Key? key,
  }) = FloatyOverlayScope<S>._;

  const FloatyOverlayScope._({
    required this.stateToJson,
    required this.stateFromJson,
    required this.initialState,
    required this.builder,
    this.maxQueueSize = 100,
    this.overflowStrategy = QueueOverflowStrategy.dropOldest,
    this.proxyTimeout = const Duration(seconds: 10),
    super.key,
  });

  /// Serializes state [S] to JSON for the state channel.
  final Map<String, dynamic> Function(S state) stateToJson;

  /// Deserializes JSON to state [S] for the state channel.
  final S Function(Map<String, dynamic> json) stateFromJson;

  /// The initial state before any updates arrive.
  final S initialState;

  /// Maximum number of queued actions while disconnected.
  final int maxQueueSize;

  /// Strategy for handling queue overflow.
  final QueueOverflowStrategy overflowStrategy;

  /// Timeout for proxy service calls.
  final Duration proxyTimeout;

  /// Builds the overlay from the kit, current state and connection status.
  final FloatyOverlayScopeBuilder<S, bool> builder;

  /// Returns the kit of the nearest [FloatyOverlayScope] ancestor; asserts
  /// that one exists.
  static FloatyOverlayKit<T> of<T>(BuildContext context) {
    final kit = maybeOf<T>(context);
    assert(
      kit != null,
      'FloatyOverlayScope.of<$T>() called without a '
      'FloatyOverlayScope<$T> ancestor.',
    );
    return kit!;
  }

  /// Returns the kit of the nearest [FloatyOverlayScope] ancestor, or
  /// `null` if none is found.
  static FloatyOverlayKit<T>? maybeOf<T>(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_FloatyOverlayScopeInherited<T>>()
      ?.kit;

  @override
  State<FloatyOverlayScope<S>> createState() => _FloatyOverlayScopeState<S>();
}
