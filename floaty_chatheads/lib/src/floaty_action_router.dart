import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';

/// {@template floaty_action}
/// Base class for typed actions dispatched between main app and overlay.
///
/// Subclass this to define your own action types:
///
/// ```dart
/// class PinAction extends FloatyAction {
///   PinAction({required this.lat, required this.lng});
///   final double lat;
///   final double lng;
///
///   @override
///   String get type => 'pin';
///
///   @override
///   Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
///
///   factory PinAction.fromJson(Map<String, dynamic> json) =>
///       PinAction(lat: json['lat'] as double, lng: json['lng'] as double);
/// }
/// ```
/// {@endtemplate}
abstract class FloatyAction {
  /// {@macro floaty_action}
  const FloatyAction();

  /// Unique type string used for routing (e.g. `'pin'`, `'navigate'`).
  String get type;

  /// Serializes the action payload to a JSON-compatible map.
  Map<String, dynamic> toJson();
}

/// A registered action handler entry.
///
/// The [handle] method deserializes and dispatches within the generic context
/// where [A] is known, avoiding runtime type errors when stored in a
/// `Map<String, _HandlerEntry<dynamic>>`.
class _HandlerEntry<A extends FloatyAction> {
  _HandlerEntry({required this.fromJson, required this.handler});

  final A Function(Map<String, dynamic> json) fromJson;
  final FutureOr<void> Function(A action) handler;

  /// Deserializes [payload] and calls [handler] in a type-safe context.
  FutureOr<void> handle(Map<String, dynamic> payload) {
    final action = fromJson(payload);
    return handler(action);
  }
}

/// {@template floaty_action_router}
/// A typed action dispatch system that replaces manual string-key matching.
///
/// Register handlers for specific action types, then dispatch actions to
/// the other side (main app ↔ overlay).
///
/// **Main app side:**
///
/// ```dart
/// final router = FloatyActionRouter();
///
/// router.on<NavigateAction>('navigate',
///   fromJson: NavigateAction.fromJson,
///   handler: (action) => mapController.move(action.target, zoom),
/// );
///
/// // Dispatch an action to the overlay.
/// router.dispatch(PinAction(lat: 12.0, lng: -86.0));
/// ```
///
/// **Overlay side:**
///
/// ```dart
/// final router = FloatyActionRouter.overlay();
///
/// router.on<PinAction>('pin',
///   fromJson: PinAction.fromJson,
///   handler: (action) => setState(() => pin = action),
/// );
/// ```
///
/// Actions coexist with raw `shareData` messages — they use a reserved
/// `_floaty_action` prefix and do not interfere with existing data streams.
/// {@endtemplate}
final class FloatyActionRouter {
  /// {@template floaty_action_router.main}
  /// Creates an action router for the **main app** side.
  /// {@endtemplate}
  FloatyActionRouter() {
    _init();
  }

  /// {@template floaty_action_router.overlay}
  /// Creates an action router for the **overlay** side.
  /// {@endtemplate}
  FloatyActionRouter.overlay() {
    _init();
  }

  static const _prefix = '_floaty_action';

  final Map<String, _HandlerEntry<dynamic>> _handlers = {};

  void _init() {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  /// Registers a handler for actions of the given [type].
  ///
  /// [fromJson] deserializes the payload into the action type.
  /// [handler] processes the deserialized action.
  void on<A extends FloatyAction>(
    String type, {
    required A Function(Map<String, dynamic> json) fromJson,
    required FutureOr<void> Function(A action) handler,
  }) {
    _handlers[type] = _HandlerEntry<A>(fromJson: fromJson, handler: handler);
  }

  /// Removes the handler for the given action [type].
  void off(String type) {
    _handlers.remove(type);
  }

  /// Dispatches an action to the other side (main app or overlay).
  ///
  /// The action is serialized and sent through the shared data channel.
  Future<void> dispatch(FloatyAction action) {
    return FloatyChannel.send({
      _prefix: {
        'type': action.type,
        'payload': action.toJson(),
      },
    });
  }

  void _onMessage(Map<String, dynamic> envelope) {
    final type = envelope['type'] as String?;
    if (type == null) return;

    final entry = _handlers[type];
    if (entry == null) return; // Unknown type — silently ignore.

    final payload = envelope['payload'];
    if (payload is! Map) return;

    try {
      final result = entry.handle(payload.cast<String, dynamic>());
      if (result is Future<void>) unawaited(result);
    } on Object {
      // Deserialization or handler error — silently ignore to avoid
      // crashing the message loop.
    }
  }

  /// Releases resources and unregisters the channel handler.
  void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    _handlers.clear();
  }
}
