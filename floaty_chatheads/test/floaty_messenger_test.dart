import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final fake = FakeFloatyPlatform();
    FloatyChatheadsPlatform.instance = fake;
    // Reset static state so each test starts clean.
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
  });

  group('FloatyMessenger', () {
    test('creates main-app messenger', () {
      final messenger = FloatyMessenger<Map<String, dynamic>>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as Map<String, dynamic>,
      );
      expect(messenger, isNotNull);
      messenger.dispose();
    });

    test('creates overlay messenger', () {
      final messenger = FloatyMessenger<String>.overlay(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );
      expect(messenger, isNotNull);
      messenger.dispose();
    });

    test('messages stream is broadcast', () {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );
      final stream = messenger.messages;
      // Should be able to listen twice (broadcast).
      stream.listen((_) {});
      stream.listen((_) {});
      messenger.dispose();
    });

    test('dispose can be called multiple times', () {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );
      messenger.dispose();
      messenger.dispose(); // Should not throw.
    });

    test('send serializes and sends via main app channel', () async {
      final messenger = FloatyMessenger<Map<String, dynamic>>(
        serialize: (value) => value,
        deserialize: (raw) => (raw! as Map).cast<String, dynamic>(),
      );

      // send should not throw even without a native handler.
      await messenger.send({'action': 'test'});
      messenger.dispose();
    });

    test('send serializes and sends via overlay channel', () async {
      FloatyOverlay.setUp();
      final messenger = FloatyMessenger<String>.overlay(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );

      // send should not throw.
      await messenger.send('hello');
      messenger.dispose();
      FloatyOverlay.dispose();
    });

    test('messages stream deserializes incoming data', () async {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );

      final received = <String>[];
      messenger.messages.listen(received.add);

      // Simulate overlay sending data.
      final encoded = const JSONMessageCodec().encodeMessage('test-msg');
      await ServicesBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(received, contains('test-msg'));

      messenger.dispose();
    });

    test('messages stream forwards deserialization errors', () async {
      final messenger = FloatyMessenger<int>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as int, // Will fail for String data.
      );

      final errors = <Object>[];
      messenger.messages.listen((_) {}, onError: errors.add);

      // Send a String which can't be cast to int.
      final encoded = const JSONMessageCodec().encodeMessage('not-an-int');
      await ServicesBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(errors, isNotEmpty);

      messenger.dispose();
    });

    test('messages getter returns same stream on repeated calls', () {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );

      final stream1 = messenger.messages;
      final stream2 = messenger.messages;
      expect(identical(stream1, stream2), isTrue);

      messenger.dispose();
    });
  });
}
