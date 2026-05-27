import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

StreamKey<Map<String, double>> _doubleKey(String name) =>
    StreamKey<Map<String, double>>(
      name: name,
      toJson: (v) => v,
      fromJson: (j) => j.cast<String, double>(),
    );

StreamKey<Map<String, int>> _intKey(String name) => StreamKey<Map<String, int>>(
      name: name,
      toJson: (v) => v,
      fromJson: (j) => j.cast<String, int>(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Object?> sentMessages;

  setUp(() {
    sentMessages = [];
    // Intercept outgoing sends.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'ni.devotion.floaty_head/messenger',
      (message) async {
        if (message != null) {
          final decoded = const JSONMessageCodec().decodeMessage(message);
          sentMessages.add(decoded);
        }
        return const JSONMessageCodec().encodeMessage(null);
      },
    );
  });

  tearDown(() {
    FloatyChannel.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'ni.devotion.floaty_head/messenger',
      null,
    );
  });

  /// Simulates an incoming message on the platform channel.
  Future<void> simulateIncoming(Object? message) async {
    final encoded = const JSONMessageCodec().encodeMessage(message);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'ni.devotion.floaty_head/messenger',
      encoded,
      (reply) {},
    );
  }

  group('FloatyProxyStream (main app side)', () {
    test('add() sends system message with name and serialized data', () async {
      final stream = FloatyProxyStream(_doubleKey('gps'));

      await stream.add({'lat': 12.0, 'lng': -86.0});

      expect(sentMessages, hasLength(1));
      final msg = sentMessages.first! as Map;
      expect(msg['__floaty__'], '_floaty_pstream');
      expect(msg['_floaty_pstream'], {
        'name': 'gps',
        'data': {'lat': 12.0, 'lng': -86.0},
      });

      await stream.dispose();
    });

    test('add() updates latest and emits on stream', () async {
      final proxyStream = FloatyProxyStream(_intKey('counter'));

      expect(proxyStream.latest, isNull);

      final values = <Map<String, int>>[];
      proxyStream.stream.listen(values.add);

      await proxyStream.add({'value': 1});
      await proxyStream.add({'value': 2});

      expect(proxyStream.latest, {'value': 2});
      expect(values, [
        {'value': 1},
        {'value': 2},
      ]);

      await proxyStream.dispose();
    });

    test('add() is a no-op on overlay-side instance', () async {
      final proxyStream = FloatyProxyStream.overlay(_intKey('test'));

      await proxyStream.add({'value': 1});

      // No messages should have been sent (the mock captures everything).
      expect(sentMessages, isEmpty);
      expect(proxyStream.latest, isNull);

      await proxyStream.dispose();
    });
  });

  group('FloatyProxyStream (overlay side)', () {
    test('receives and deserializes incoming values', () async {
      final proxyStream = FloatyProxyStream.overlay(_doubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': {'lat': 12.0, 'lng': -86.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, hasLength(1));
      expect(values.first, {'lat': 12.0, 'lng': -86.0});
      expect(proxyStream.latest, {'lat': 12.0, 'lng': -86.0});

      await proxyStream.dispose();
    });

    test('ignores messages with different name', () async {
      final proxyStream = FloatyProxyStream.overlay(_doubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gyroscope',
          'data': {'x': 1.0, 'y': 2.0, 'z': 3.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
      expect(proxyStream.latest, isNull);

      await proxyStream.dispose();
    });

    test('ignores messages with non-map data', () async {
      final proxyStream = FloatyProxyStream.overlay(_doubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': 'not a map',
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);

      await proxyStream.dispose();
    });

    test('survives deserialization errors without crashing', () async {
      final proxyStream = FloatyProxyStream<Map<String, double>>.overlay(
        StreamKey<Map<String, double>>(
          name: 'gps',
          toJson: (v) => v,
          fromJson: (j) => throw const FormatException('bad data'),
        ),
      );

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      // Should not throw.
      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': {'lat': 12.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
      expect(proxyStream.latest, isNull);

      await proxyStream.dispose();
    });

    test('receives multiple values in order', () async {
      final proxyStream = FloatyProxyStream.overlay(_doubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      for (var i = 0; i < 5; i++) {
        await simulateIncoming({
          '__floaty__': '_floaty_pstream',
          '_floaty_pstream': {
            'name': 'gps',
            'data': {'lat': i.toDouble()},
          },
        });
      }

      await Future<void>.delayed(Duration.zero);

      expect(values, hasLength(5));
      for (var i = 0; i < 5; i++) {
        expect(values[i], {'lat': i.toDouble()});
      }
      expect(proxyStream.latest, {'lat': 4.0});

      await proxyStream.dispose();
    });
  });

  group('FloatyProxyStream multiple streams', () {
    test('two streams with different names coexist independently', () async {
      final accel = FloatyProxyStream.overlay(_doubleKey('accel'));
      final light = FloatyProxyStream.overlay(_doubleKey('light'));

      final accelValues = <Map<String, double>>[];
      final lightValues = <Map<String, double>>[];
      accel.stream.listen(accelValues.add);
      light.stream.listen(lightValues.add);

      // Send accel message.
      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'accel',
          'data': {'x': 1.0, 'y': 9.8},
        },
      });
      // Send light message.
      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'light',
          'data': {'lux': 350.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(accelValues, hasLength(1));
      expect(accelValues.first, {'x': 1.0, 'y': 9.8});
      expect(lightValues, hasLength(1));
      expect(lightValues.first, {'lux': 350.0});

      await accel.dispose();
      await light.dispose();
    });

    test('disposing one stream does not affect the other', () async {
      final stream1 = FloatyProxyStream.overlay(_doubleKey('stream1'));
      final stream2 = FloatyProxyStream.overlay(_doubleKey('stream2'));

      final values1 = <Map<String, double>>[];
      final values2 = <Map<String, double>>[];
      stream1.stream.listen(values1.add);
      stream2.stream.listen(values2.add);

      // Dispose stream1.
      await stream1.dispose();

      // stream2 should still work.
      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'stream2',
          'data': {'value': 42.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values1, isEmpty);
      expect(values2, hasLength(1));
      expect(values2.first, {'value': 42.0});

      await stream2.dispose();
    });
  });

  group('FloatyProxyStream duplicate name', () {
    test('throws StateError when registering a duplicate name', () async {
      final first = FloatyProxyStream(_doubleKey('dup'));

      expect(
        () => FloatyProxyStream(_doubleKey('dup')),
        throwsStateError,
      );

      await first.dispose();
    });

    test('allows re-registration after dispose', () async {
      final first = FloatyProxyStream(_doubleKey('reuse'));
      await first.dispose();
      expect(first, isNotNull);
      // Should not throw — name was freed by dispose.
      final second = FloatyProxyStream(_doubleKey('reuse'));
      await second.dispose();
      expect(second, isNotNull);
    });
  });

  group('FloatyProxyStream dispose', () {
    test('dispose unregisters handler', () async {
      final proxyStream = FloatyProxyStream.overlay(_doubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await proxyStream.dispose();

      // Messages after dispose should not reach the stream.
      await simulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': {'lat': 99.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
    });
  });
}
