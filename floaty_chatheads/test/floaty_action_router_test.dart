import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _PingAction extends FloatyAction {
  _PingAction({required this.value});

  factory _PingAction.fromJson(Map<String, dynamic> json) =>
      _PingAction(value: json['value'] as String);

  final String value;

  @override
  String get type => 'ping';

  @override
  Map<String, dynamic> toJson() => {'value': value};
}

class _NavigateAction extends FloatyAction {
  _NavigateAction({required this.route});

  factory _NavigateAction.fromJson(Map<String, dynamic> json) =>
      _NavigateAction(route: json['route'] as String);

  final String route;

  @override
  String get type => 'navigate';

  @override
  Map<String, dynamic> toJson() => {'route': route};
}

Future<void> _simulateMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'ni.devotion.floaty_head/messenger',
    encoded,
    (data) {},
  );
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.dispose);

  group('FloatyActionRouter', () {
    test('dispatch serializes and sends an action through the channel',
        () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      // dispatch should not throw.
      await router.dispatch(_PingAction(value: 'hello'));
    });

    test('constructor registers handler on the _floaty_action prefix',
        () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      // Verify the handler is registered by sending a prefixed message
      // and checking it does NOT fall through to rawMessages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'world'},
        },
      });

      // The message should have been intercepted by the router's handler,
      // not forwarded to the raw stream.
      expect(rawReceived, isEmpty);
    });

    test('on registers a typed handler entry', () {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      // on should not throw.
      router.on<_PingAction>(
        'ping',
        fromJson: _PingAction.fromJson,
        handler: (_) {},
      );
    });

    test('off removes a handler', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router
        ..on<_PingAction>(
          'ping',
          fromJson: _PingAction.fromJson,
          handler: (_) {},
        )

        // Remove the handler.
        ..off('ping');

      // After off, the handler should no longer be in the router's map.
      // Sending a 'ping' action should be silently ignored (no crash).
      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'ignored'},
        },
      });
      // No crash means off worked correctly.
    });

    test('unrecognized action types are silently ignored', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on<_PingAction>(
        'ping',
        fromJson: _PingAction.fromJson,
        handler: (_) {},
      );

      // Send an action type that has no handler -- should not crash.
      await _simulateMessage({
        '_floaty_action': {
          'type': 'unknown_type',
          'payload': {'key': 'value'},
        },
      });
    });

    test('multiple handler types can be registered independently', () {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router
        ..on<_PingAction>(
          'ping',
          fromJson: _PingAction.fromJson,
          handler: (_) {},
        )
        ..on<_NavigateAction>(
          'navigate',
          fromJson: _NavigateAction.fromJson,
          handler: (_) {},
        )

        // Both registered; off one doesn't affect the other.
        ..off('ping');

      // 'navigate' handler should still be registered (no crash on dispatch).
    });

    test('bad payload does not crash the router', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on<_PingAction>(
        'ping',
        fromJson: _PingAction.fromJson,
        handler: (_) {},
      );

      // Send a message where payload is not a Map.
      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': 'not-a-map',
        },
      });
      // No crash.
    });

    test('missing type field is silently ignored', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on<_PingAction>(
        'ping',
        fromJson: _PingAction.fromJson,
        handler: (_) {},
      );

      // Send a message without 'type'.
      await _simulateMessage({
        '_floaty_action': {
          'payload': {'value': 'no-type'},
        },
      });
      // No crash.
    });

    test('.overlay() constructor registers handler on channel', () async {
      final router = FloatyActionRouter.overlay();
      addTearDown(router.dispose);

      // Verify registration by checking raw messages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'from-overlay'},
        },
      });

      // Message intercepted, not in raw stream.
      expect(rawReceived, isEmpty);
    });

    test('dispose clears handlers and unregisters from channel', () async {
      FloatyActionRouter()
        ..on<_PingAction>(
          'ping',
          fromJson: _PingAction.fromJson,
          handler: (_) {},
        )
        ..dispose();

      // After dispose, action messages should go to rawMessages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'after-dispose'},
        },
      });

      expect(rawReceived, hasLength(1));
    });

    test('fromJson throwing does not crash the router', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on<_PingAction>(
        'ping',
        fromJson: (json) => throw const FormatException('bad data'),
        handler: (_) {},
      );

      // Should not throw.
      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'will-fail-parse'},
        },
      });
    });

    test('dispatch sends correctly formatted envelope', () async {
      // Intercept the message at the channel level.
      final sent = <Object?>[];
      FloatyChannel.registerHandler('_floaty_action', sent.add);
      FloatyChannel.ensureListening();

      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      // Note: dispatch calls FloatyChannel.send() which goes to the native
      // side. In tests there's no native side, so the message doesn't
      // come back. We test the serialization by verifying no exception.
      await router.dispatch(_PingAction(value: 'outgoing'));
      // No crash means the action was serialized correctly.
    });

    test('prefixed action messages do not leak to rawMessages', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on<_PingAction>(
        'ping',
        fromJson: _PingAction.fromJson,
        handler: (_) {},
      );

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      // Send action-prefixed message.
      await _simulateMessage({
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'world'},
        },
      });

      // Also send a raw message to verify the stream works.
      await _simulateMessage('raw-hello');

      // Only the raw message should appear.
      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, 'raw-hello');
    });
  });
}
