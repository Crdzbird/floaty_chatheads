import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_reset_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(messengerResetPlatform);

  group('FloatyMessenger', () {
    test('creates main-app messenger', () async {
      final messenger = FloatyMessenger<Map<String, dynamic>>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as Map<String, dynamic>,
      );
      expect(messenger, isNotNull);
      await messenger.dispose();
    });

    test('creates overlay messenger', () async {
      final messenger = FloatyMessenger<String>.overlay(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );
      expect(messenger, isNotNull);
      await messenger.dispose();
    });

    test('messages stream is broadcast', () async {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );
      messenger.messages
        ..listen((_) {})
        ..listen((_) {});
      await messenger.dispose();
    });

    test('dispose can be called multiple times', () async {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );
      await Future.wait([messenger.dispose(), messenger.dispose()]);
    });

    test('messages getter returns same stream on repeated calls', () async {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );

      final stream1 = messenger.messages;
      final stream2 = messenger.messages;
      expect(identical(stream1, stream2), isTrue);

      await messenger.dispose();
    });
  });
}
