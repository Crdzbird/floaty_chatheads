import 'dart:async';

import 'package:floaty_chatheads/src/floaty_action_router.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';
import 'package:floaty_chatheads/src/floaty_proxy.dart';
import 'package:floaty_chatheads/src/floaty_state_channel.dart';

/// {@template floaty_host_kit}
/// All-in-one communication bundle for the **main app** side.
///
/// Bundles [FloatyActionRouter], [FloatyStateChannel], and
/// [FloatyProxyHost] into a single object with one [dispose] call.
///
/// ```dart
/// final kit = FloatyHostKit<MyState>(
///   stateToJson: (s) => s.toJson(),
///   stateFromJson: MyState.fromJson,
///   initialState: MyState(),
/// );
///
/// kit.onAction<IncrementAction>('increment',
///   fromJson: IncrementAction.fromJson,
///   handler: (a) => counter += a.amount,
/// );
///
/// kit.registerService('time', (method, params) {
///   return DateTime.now().toIso8601String();
/// });
///
/// await kit.setState(MyState(counter: 42));
/// ```
///
/// Use the component getters ([router], [stateChannel], [proxyHost])
/// when you need direct access to the underlying objects.
///
/// **Important:** Do not create standalone [FloatyActionRouter],
/// [FloatyStateChannel], or [FloatyProxyHost] instances alongside a
/// Kit — they register on the same channel prefixes and would collide.
/// {@endtemplate}
final class FloatyHostKit<S> {
  /// {@macro floaty_host_kit}
  FloatyHostKit({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    int maxQueueSize = 100,
    QueueOverflowStrategy overflowStrategy =
        QueueOverflowStrategy.dropOldest,
  })  : _router = FloatyActionRouter(
          maxQueueSize: maxQueueSize,
          overflowStrategy: overflowStrategy,
        ),
        _stateChannel = FloatyStateChannel<S>(
          toJson: stateToJson,
          fromJson: stateFromJson,
          initialState: initialState,
        ),
        _proxyHost = FloatyProxyHost();

  final FloatyActionRouter _router;
  final FloatyStateChannel<S> _stateChannel;
  final FloatyProxyHost _proxyHost;

  // ── Component access ──────────────────────────────────────────────

  /// The underlying action router.
  FloatyActionRouter get router => _router;

  /// The underlying state channel.
  FloatyStateChannel<S> get stateChannel => _stateChannel;

  /// The underlying proxy host.
  FloatyProxyHost get proxyHost => _proxyHost;

  // ── Action delegates ──────────────────────────────────────────────

  /// Registers a handler for actions of the given [type].
  void onAction<A extends FloatyAction>(
    String type, {
    required A Function(Map<String, dynamic> json) fromJson,
    required FutureOr<void> Function(A action) handler,
  }) =>
      _router.on<A>(type, fromJson: fromJson, handler: handler);

  /// Removes the handler for the given action [type].
  void offAction(String type) => _router.off(type);

  /// Dispatches an action to the overlay.
  Future<void> dispatch(FloatyAction action) => _router.dispatch(action);

  /// The number of actions currently queued (always 0 on host side).
  int get queueLength => _router.queueLength;

  // ── State delegates ───────────────────────────────────────────────

  /// The current state (synchronous read).
  S get state => _stateChannel.state;

  /// Stream of state changes from the overlay.
  Stream<S> get onStateChanged => _stateChannel.onStateChanged;

  /// Replaces the entire state and syncs to the overlay.
  Future<void> setState(S newState) => _stateChannel.setState(newState);

  /// Shallow-merges [partial] into the current state and syncs.
  Future<void> updateState(Map<String, dynamic> partial) =>
      _stateChannel.updateState(partial);

  // ── Proxy delegates ───────────────────────────────────────────────

  /// Registers a service provider callable from the overlay.
  void registerService(
    String service,
    FutureOr<Object?> Function(
      String method,
      Map<String, dynamic> params,
    ) handler,
  ) =>
      _proxyHost.register(service, handler);

  /// Removes a registered service provider.
  void unregisterService(String service) =>
      _proxyHost.unregister(service);

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Releases all resources — disposes the router, state channel, and
  /// proxy host in sequence.
  void dispose() {
    _router.dispose();
    _stateChannel.dispose();
    _proxyHost.dispose();
  }
}

/// {@template floaty_overlay_kit}
/// All-in-one communication bundle for the **overlay** side.
///
/// Bundles [FloatyActionRouter] (overlay mode with queueing),
/// [FloatyStateChannel], [FloatyProxyClient], and
/// [FloatyConnectionState] into a single object with one [dispose]
/// call.
///
/// ```dart
/// final kit = FloatyOverlayKit<MyState>(
///   stateToJson: (s) => s.toJson(),
///   stateFromJson: MyState.fromJson,
///   initialState: MyState(),
/// );
///
/// kit.dispatch(IncrementAction(amount: 1)); // queues if disconnected
/// final time = await kit.callService('time', 'now',
///   fallback: () => 'offline',
/// );
///
/// kit.onStateChanged.listen((state) {
///   setState(() => _state = state);
/// });
///
/// print('Connected: ${kit.isConnected}');
/// print('Queued: ${kit.queueLength}');
/// ```
///
/// **Important:** Do not create standalone [FloatyActionRouter],
/// [FloatyStateChannel], or [FloatyProxyClient] instances alongside a
/// Kit — they register on the same channel prefixes and would collide.
/// {@endtemplate}
final class FloatyOverlayKit<S> {
  /// {@macro floaty_overlay_kit}
  FloatyOverlayKit({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    int maxQueueSize = 100,
    QueueOverflowStrategy overflowStrategy =
        QueueOverflowStrategy.dropOldest,
    Duration proxyTimeout = const Duration(seconds: 10),
  })  : _router = FloatyActionRouter.overlay(
          maxQueueSize: maxQueueSize,
          overflowStrategy: overflowStrategy,
        ),
        _stateChannel = FloatyStateChannel<S>.overlay(
          toJson: stateToJson,
          fromJson: stateFromJson,
          initialState: initialState,
        ),
        _proxyClient = FloatyProxyClient(timeout: proxyTimeout) {
    FloatyConnectionState.setUp();
  }

  final FloatyActionRouter _router;
  final FloatyStateChannel<S> _stateChannel;
  final FloatyProxyClient _proxyClient;

  // ── Component access ──────────────────────────────────────────────

  /// The underlying action router (overlay mode).
  FloatyActionRouter get router => _router;

  /// The underlying state channel.
  FloatyStateChannel<S> get stateChannel => _stateChannel;

  /// The underlying proxy client.
  FloatyProxyClient get proxyClient => _proxyClient;

  // ── Action delegates ──────────────────────────────────────────────

  /// Registers a handler for actions of the given [type].
  void onAction<A extends FloatyAction>(
    String type, {
    required A Function(Map<String, dynamic> json) fromJson,
    required FutureOr<void> Function(A action) handler,
  }) =>
      _router.on<A>(type, fromJson: fromJson, handler: handler);

  /// Removes the handler for the given action [type].
  void offAction(String type) => _router.off(type);

  /// Dispatches an action to the main app.
  ///
  /// If the main app is disconnected, the action is queued and will
  /// be sent when the connection is restored.
  Future<void> dispatch(FloatyAction action) => _router.dispatch(action);

  /// The number of actions currently queued (waiting for reconnection).
  int get queueLength => _router.queueLength;

  // ── State delegates ───────────────────────────────────────────────

  /// The current state (synchronous read).
  S get state => _stateChannel.state;

  /// Stream of state changes from the main app.
  Stream<S> get onStateChanged => _stateChannel.onStateChanged;

  /// Replaces the entire state and syncs to the main app.
  Future<void> setState(S newState) => _stateChannel.setState(newState);

  /// Shallow-merges [partial] into the current state and syncs.
  Future<void> updateState(Map<String, dynamic> partial) =>
      _stateChannel.updateState(partial);

  // ── Proxy delegates ───────────────────────────────────────────────

  /// Calls a service method on the main app.
  ///
  /// Returns the result, or the [fallback] value if the main app is
  /// disconnected. Throws [FloatyProxyDisconnectedException] if
  /// disconnected and no fallback is provided.
  Future<Object?> callService(
    String service,
    String method, {
    Map<String, dynamic> params = const {},
    Object? Function()? fallback,
  }) =>
      _proxyClient.call(
        service,
        method,
        params: params,
        fallback: fallback,
      );

  // ── Connection delegates ──────────────────────────────────────────

  /// Whether the main app is currently connected.
  bool get isConnected => FloatyConnectionState.isMainAppConnected;

  /// Stream that fires on connect / disconnect transitions.
  Stream<bool> get onConnectionChanged =>
      FloatyConnectionState.onConnectionChanged;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Releases all resources — disposes the router, state channel, and
  /// proxy client in sequence.
  ///
  /// Does **not** dispose [FloatyConnectionState] (it is a shared
  /// singleton).
  void dispose() {
    _router.dispose();
    _stateChannel.dispose();
    _proxyClient.dispose();
  }
}
