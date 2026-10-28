import 'dart:async';

import 'package:floaty_chatheads/src/floaty_action_router.dart';
import 'package:floaty_chatheads/src/floaty_proxy.dart';
import 'package:floaty_chatheads/src/floaty_state_channel.dart';
import 'package:floaty_chatheads/src/kit/floaty_kit_members.dart';

/// All-in-one communication bundle for the main app side.
///
/// Bundles [FloatyActionRouter], [FloatyStateChannel] and
/// [FloatyProxyHost] behind one [dispose] call:
///
/// ```dart
/// final kit = FloatyHostKit<MyState>(
///   stateToJson: (s) => s.toJson(),
///   stateFromJson: MyState.fromJson,
///   initialState: MyState(),
/// )..onAction(IncrementAction.key, (a) => counter += a.amount);
/// await kit.setState(MyState(counter: 42));
/// ```
///
/// Do not create standalone routers, state channels or proxy hosts next
/// to a kit: they register on the same channel prefixes and would collide.
final class FloatyHostKit<S> with FloatyKitMembers<S> {
  /// Creates the host kit and its components.
  factory FloatyHostKit({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    int maxQueueSize,
    QueueOverflowStrategy overflowStrategy,
  }) = FloatyHostKit<S>._;

  FloatyHostKit._({
    required Map<String, dynamic> Function(S state) stateToJson,
    required S Function(Map<String, dynamic> json) stateFromJson,
    required S initialState,
    int maxQueueSize = 100,
    QueueOverflowStrategy overflowStrategy = QueueOverflowStrategy.dropOldest,
  }) : router = FloatyActionRouter(
         maxQueueSize: maxQueueSize,
         overflowStrategy: overflowStrategy,
       ),
       stateChannel = FloatyStateChannel<S>(
         toJson: stateToJson,
         fromJson: stateFromJson,
         initialState: initialState,
       ),
       proxyHost = FloatyProxyHost();

  @override
  final FloatyActionRouter router;

  @override
  final FloatyStateChannel<S> stateChannel;

  /// The underlying proxy host.
  final FloatyProxyHost proxyHost;

  /// Registers a service provider callable from the overlay.
  void registerService(
    String service,
    FutureOr<Object?> Function(String method, Map<String, dynamic> params)
    handler,
  ) => proxyHost.register(service, handler);

  /// Removes a registered service provider.
  void unregisterService(String service) => proxyHost.unregister(service);

  /// Disposes the router, state channel and proxy host.
  Future<void> dispose() async {
    await Future.wait([router.dispose(), stateChannel.dispose()]);
    proxyHost.dispose();
  }
}
