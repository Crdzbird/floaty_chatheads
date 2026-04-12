import 'dart:async';

import 'package:floaty_chatheads/src/floaty_action_router.dart';
import 'package:floaty_chatheads/src/floaty_kit.dart';
import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_overlay_scope}
/// A reactive scope widget that combines [FloatyOverlayKit] with automatic
/// stream management, removing **all** boilerplate from overlay widgets.
///
/// Instead of manually creating a kit, subscribing to streams, and
/// disposing everything in three lifecycle methods, wrap your overlay
/// content in a single [FloatyOverlayScope]:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(
///   FloatyOverlayScope<MyState>(
///     stateToJson: (s) => s.toJson(),
///     stateFromJson: MyState.fromJson,
///     initialState: MyState(),
///     builder: (context, kit, state, connected) {
///       return Column(children: [
///         Text(connected ? 'Online' : 'Offline'),
///         Text('Counter: ${state.counter}'),
///         ElevatedButton(
///           onPressed: () => kit.dispatch(IncrementAction(amount: 1)),
///           child: Text('+1 (queued: ${kit.queueLength})'),
///         ),
///       ]);
///     },
///   ),
/// );
/// ```
///
/// The scope:
///
/// - Creates and owns a [FloatyOverlayKit] instance.
/// - Calls [FloatyOverlay.setUp] automatically.
/// - Subscribes to [FloatyOverlayKit.onStateChanged] and
///   [FloatyOverlayKit.onConnectionChanged].
/// - Rebuilds the [builder] whenever state or connection changes.
/// - Disposes the kit, subscriptions, and [FloatyOverlay] on unmount.
///
/// Access the kit from any descendant via [FloatyOverlayScope.of].
/// {@endtemplate}
final class FloatyOverlayScope<S> extends StatefulWidget {
  /// {@macro floaty_overlay_scope}
  const FloatyOverlayScope({
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

  /// Builder that receives the kit, current state, and connection status.
  ///
  /// Rebuilds automatically whenever the state or connection changes.
  final Widget Function(
    BuildContext context,
    FloatyOverlayKit<S> kit,
    S state,
    // ignore: avoid_positional_boolean_parameters, builder callback
    bool connected,
  ) builder;

  /// Returns the [FloatyOverlayKit] from the nearest ancestor
  /// [FloatyOverlayScope].
  ///
  /// Throws if no scope is found in the widget tree.
  static FloatyOverlayKit<T> of<T>(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_FloatyOverlayScopeInherited<T>>();
    assert(
      inherited != null,
      'FloatyOverlayScope.of<$T>() called without a '
      'FloatyOverlayScope<$T> ancestor.',
    );
    return inherited!.kit;
  }

  /// Returns the [FloatyOverlayKit] from the nearest ancestor
  /// [FloatyOverlayScope], or `null` if none is found.
  static FloatyOverlayKit<T>? maybeOf<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_FloatyOverlayScopeInherited<T>>()
        ?.kit;
  }

  @override
  State<FloatyOverlayScope<S>> createState() =>
      _FloatyOverlayScopeState<S>();
}

class _FloatyOverlayScopeState<S> extends State<FloatyOverlayScope<S>> {
  late final FloatyOverlayKit<S> _kit;
  late S _state;
  late bool _connected;

  StreamSubscription<S>? _stateSub;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    _kit = FloatyOverlayKit<S>(
      stateToJson: widget.stateToJson,
      stateFromJson: widget.stateFromJson,
      initialState: widget.initialState,
      maxQueueSize: widget.maxQueueSize,
      overflowStrategy: widget.overflowStrategy,
      proxyTimeout: widget.proxyTimeout,
    );

    _state = widget.initialState;
    _connected = _kit.isConnected;

    _stateSub = _kit.onStateChanged.listen((state) {
      if (mounted) setState(() => _state = state);
    });

    _connSub = _kit.onConnectionChanged.listen((connected) {
      if (mounted) setState(() => _connected = connected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FloatyOverlayScopeInherited<S>(
      kit: _kit,
      child: widget.builder(context, _kit, _state, _connected),
    );
  }

  @override
  void dispose() {
    unawaited(_tearDown());
    super.dispose();
  }

  Future<void> _tearDown() async {
    await Future.wait([
      if (_stateSub != null) _stateSub!.cancel(),
      if (_connSub != null) _connSub!.cancel(),
      _kit.dispose(),
    ]);
    FloatyOverlay.dispose();
  }
}

class _FloatyOverlayScopeInherited<S> extends InheritedWidget {
  const _FloatyOverlayScopeInherited({
    required this.kit,
    required super.child,
  });

  final FloatyOverlayKit<S> kit;

  @override
  bool updateShouldNotify(_FloatyOverlayScopeInherited<S> oldWidget) =>
      !identical(kit, oldWidget.kit);
}
