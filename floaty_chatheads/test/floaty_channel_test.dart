import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Wraps a prefixed payload in the system envelope used by [FloatyChannel].
Map<String, Object?> _sys(String prefix, Map<String, dynamic> payload) =>
    <String, Object?>{'__floaty__': prefix, prefix: payload};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.dispose();
  });

  group('FloatyChannel', () {
    test('messages with _floaty_state prefix are routed to registered handler',
        () async {
      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler(
        '_floaty_state',
        received.add,
      );
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage(
        _sys('_floaty_state', {'full': true, 'data': {'count': 1}}),
      );

      expect(received, hasLength(1));
      expect(received.first['full'], true);
      expect(rawReceived, isEmpty);
    });

    test('messages with _floaty_action prefix are routed to registered handler',
        () async {
      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler(
        '_floaty_action',
        received.add,
      );
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage(
        _sys(
          '_floaty_action',
          {'type': 'ping', 'payload': <String, dynamic>{}},
        ),
      );

      expect(received, hasLength(1));
      expect(received.first['type'], 'ping');
      expect(rawReceived, isEmpty);
    });

    test('messages with _floaty_proxy prefix are routed to registered handler',
        () async {
      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler(
        '_floaty_proxy',
        received.add,
      );
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage(
        _sys('_floaty_proxy', {'id': '0', 'type': 'request'}),
      );

      expect(received, hasLength(1));
      expect(received.first['type'], 'request');
      expect(rawReceived, isEmpty);
    });

    test('raw messages without a prefix are forwarded to rawMessages stream',
        () async {
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({'action': 'test', 'value': 42});

      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, isA<Map<dynamic, dynamic>>());
    });

    test('registering and unregistering handlers works', () async {
      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler(
        '_floaty_state',
        received.add,
      );
      FloatyChannel.ensureListening();

      await _simulateMessage(
        _sys('_floaty_state', {'full': true, 'data': <String, dynamic>{}}),
      );
      expect(received, hasLength(1));

      // Unregister the handler.
      FloatyChannel.unregisterHandler('_floaty_state');

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage(
        _sys('_floaty_state', {'full': true, 'data': <String, dynamic>{}}),
      );

      // After unregistering, message should go to raw stream.
      expect(received, hasLength(1)); // no additional calls
      expect(rawReceived, hasLength(1));
    });

    test('dispose clears all state and allows re-listening', () async {
      FloatyChannel.registerHandler(
        '_floaty_state',
        (data) {},
      );
      FloatyChannel.ensureListening();

      FloatyChannel.dispose();

      // After dispose, re-register and re-listen.
      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler(
        '_floaty_state',
        received.add,
      );
      FloatyChannel.ensureListening();

      await _simulateMessage(
        _sys('_floaty_state', {'key': 'value'}),
      );

      expect(received, hasLength(1));
    });

    test('multiple handlers can coexist', () async {
      final stateReceived = <Map<String, dynamic>>[];
      final actionReceived = <Map<String, dynamic>>[];
      final proxyReceived = <Map<String, dynamic>>[];

      FloatyChannel.registerHandler(
        '_floaty_state',
        stateReceived.add,
      );
      FloatyChannel.registerHandler(
        '_floaty_action',
        actionReceived.add,
      );
      FloatyChannel.registerHandler(
        '_floaty_proxy',
        proxyReceived.add,
      );
      FloatyChannel.ensureListening();

      await _simulateMessage(
        _sys(
          '_floaty_state',
          {'full': true, 'data': <String, dynamic>{}},
        ),
      );
      await _simulateMessage(
        _sys(
          '_floaty_action',
          {'type': 'ping', 'payload': <String, dynamic>{}},
        ),
      );
      await _simulateMessage(
        _sys(
          '_floaty_proxy',
          {'id': '0', 'type': 'request'},
        ),
      );

      expect(stateReceived, hasLength(1));
      expect(actionReceived, hasLength(1));
      expect(proxyReceived, hasLength(1));
    });

    test('non-Map messages go to raw stream', () async {
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage('just a string');

      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, 'just a string');
    });

    test('null messages go to raw stream', () async {
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage(null);

      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, isNull);
    });

    test('map with prefix key but non-map value goes to raw stream', () async {
      FloatyChannel.registerHandler('_floaty_state', (_) {});
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      // The value for _floaty_state is a string, not a Map.
      await _simulateMessage(
        {'__floaty__': '_floaty_state', '_floaty_state': 'not-a-map'},
      );

      expect(rawReceived, hasLength(1));
    });

    test('map without system envelope goes to raw stream even with prefix key',
        () async {
      FloatyChannel.registerHandler('_floaty_state', (_) {});
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      // User data that happens to contain a prefix key but no envelope.
      await _simulateMessage({'_floaty_state': {'full': true}});

      expect(rawReceived, hasLength(1));
    });

    test('ensureListening is safe to call multiple times', () {
      FloatyChannel.ensureListening();
      FloatyChannel.ensureListening();
      FloatyChannel.ensureListening();
      // No errors thrown.
    });

    test('send transmits data through the channel', () async {
      // send should not throw even without a native handler.
      await FloatyChannel.send({'key': 'value'});
    });

    test('sendSystem wraps payload in system envelope', () async {
      // sendSystem should not throw even without a native handler.
      await FloatyChannel.sendSystem('_floaty_state', {'key': 'value'});
    });
  });
}
