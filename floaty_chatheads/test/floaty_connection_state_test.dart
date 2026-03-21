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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyConnectionState.dispose();
    FloatyChannel.dispose();
  });

  tearDown(() {
    FloatyConnectionState.dispose();
    FloatyChannel.dispose();
  });

  group('FloatyConnectionState', () {
    test('setUp registers handler and enables listening', () async {
      FloatyConnectionState.setUp();

      // Verify the handler is registered by sending a prefixed
      // message and checking it does NOT fall through to rawMessages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });

      expect(rawReceived, isEmpty);
    });

    test('isMainAppConnected defaults to true', () {
      expect(FloatyConnectionState.isMainAppConnected, isTrue);
    });

    test(
      'receiving {"connected": false} updates state and emits on '
      'stream',
      () async {
        FloatyConnectionState.setUp();

        final emissions = <bool>[];
        FloatyConnectionState.onConnectionChanged.listen(
          emissions.add,
        );

        await _simulateMessage({
          '__floaty__': '_floaty_connection',
          '_floaty_connection': {'connected': false},
        });

        expect(
          FloatyConnectionState.isMainAppConnected,
          isFalse,
        );
        expect(emissions, [false]);
      },
    );

    test(
      'receiving {"connected": true} updates state and emits on '
      'stream',
      () async {
        FloatyConnectionState.setUp();

        final emissions = <bool>[];
        FloatyConnectionState.onConnectionChanged.listen(
          emissions.add,
        );

        // First disconnect.
        await _simulateMessage({
          '__floaty__': '_floaty_connection',
          '_floaty_connection': {'connected': false},
        });

        // Then reconnect.
        await _simulateMessage({
          '__floaty__': '_floaty_connection',
          '_floaty_connection': {'connected': true},
        });

        expect(
          FloatyConnectionState.isMainAppConnected,
          isTrue,
        );
        expect(emissions, [false, true]);
      },
    );

    test('duplicate values do not emit', () async {
      FloatyConnectionState.setUp();

      final emissions = <bool>[];
      FloatyConnectionState.onConnectionChanged.listen(
        emissions.add,
      );

      // Default is true; sending true again should not emit.
      await _simulateMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });

      expect(emissions, isEmpty);

      // Now change to false — should emit once.
      await _simulateMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      // Sending false again should not emit.
      await _simulateMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(emissions, [false]);
    });

    test('dispose resets state', () async {
      FloatyConnectionState.setUp();

      // Disconnect first.
      await _simulateMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(
        FloatyConnectionState.isMainAppConnected,
        isFalse,
      );

      FloatyConnectionState.dispose();

      // After dispose, the default should be restored.
      expect(
        FloatyConnectionState.isMainAppConnected,
        isTrue,
      );
    });

    test('setUp is idempotent (safe to call multiple times)', () async {
      FloatyConnectionState.setUp();
      FloatyConnectionState.setUp();
      FloatyConnectionState.setUp();

      final emissions = <bool>[];
      FloatyConnectionState.onConnectionChanged.listen(
        emissions.add,
      );

      await _simulateMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      // Should emit exactly once, not three times.
      expect(emissions, [false]);
    });
  });
}
