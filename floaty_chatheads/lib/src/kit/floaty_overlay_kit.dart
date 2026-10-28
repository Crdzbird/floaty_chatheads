import 'dart:async';

import 'package:floaty_chatheads/src/floaty_action_router.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';
import 'package:floaty_chatheads/src/floaty_proxy.dart';
import 'package:floaty_chatheads/src/floaty_state_channel.dart';
import 'package:floaty_chatheads/src/kit/floaty_kit_members.dart';

/// All-in-one communication bundle for the overlay side.
///
/// Bundles [FloatyActionRouter] (overlay mode with queueing),
/// [FloatyStateChannel], [FloatyProxyClient] and [FloatyConnectionState]
/// behind one [dispose] call:
///
/// ```dart
/// final kit = FloatyOverlayKit<MyState>(
///   stateToJson: (s) => s.toJson(),
///   stateFromJson: MyState.fromJson,
///   initialState: MyState(),
/// );
/// await kit.dispatch(IncrementAction(amount: 1));
/// final time = await kit.callService('time', 'now', fallback: () => '');
/// ```
///
/// Do not create standalone routers, state channels or proxy clients next
/// to a kit: they register on the same channel prefixes and would collide.
final class FloatyOverlayKit<S> with FloatyKitMembers<S> {
  /// Creates the overlay kit and its components.
  factory FloatyOverlayKit({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    int maxQueueSize,
    QueueOverflowStrategy overflowStrategy,
    Duration proxyTimeout,
  }) = FloatyOverlayKit<S>._;

  FloatyOverlayKit._({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    int maxQueueSize = 100,
    QueueOverflowStrategy overflowStrategy = QueueOverflowStrategy.dropOldest,
    Duration proxyTimeout = const Duration(seconds: 10),
  }) : router = FloatyActionRouter.overlay(
         maxQueueSize: maxQueueSize,
         overflowStrategy: overflowStrategy,
       ),
       stateChannel = FloatyStateChannel<S>.overlay(
         toJson: stateToJson,
         fromJson: stateFromJson,
         initialState: initialState,
       ),
       proxyClient = FloatyProxyClient(timeout: proxyTimeout) {
    FloatyConnectionState.setUp();
  }

  @override
  final FloatyActionRouter router;

  @override
  final FloatyStateChannel<S> stateChannel;

  /// The underlying proxy client.
  final FloatyProxyClient proxyClient;

  /// Calls a service method on the main app, returning [fallback]'s value
  /// when the main app is disconnected (or throwing
  /// [FloatyProxyDisconnectedException] without a fallback).
  Future<Object?> callService(
    String service,
    String method, {
    Map<String, dynamic> params = const {},
    Object? Function()? fallback,
  }) => proxyClient.call(service, method, params: params, fallback: fallback);

  /// Whether the main app is currently connected.
  bool get isConnected => FloatyConnectionState.isMainAppConnected;

  /// Stream that fires on connect and disconnect transitions.
  Stream<bool> get onConnectionChanged =>
      FloatyConnectionState.onConnectionChanged;

  /// Disposes the router, state channel and proxy client. Does not dispose
  /// the shared [FloatyConnectionState].
  Future<void> dispose() async {
    await Future.wait([router.dispose(), stateChannel.dispose()]);
    proxyClient.dispose();
  }
}
