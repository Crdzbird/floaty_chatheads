import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_reset_platform.dart';
import '../helpers/send_messenger_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(messengerResetPlatform);

  group('FloatyMessenger', () {
    test('send serializes and sends via main app channel', () async {
      final messenger = FloatyMessenger<Map<String, dynamic>>(
        serialize: (value) => value,
        deserialize: (raw) => (raw! as Map).cast<String, dynamic>(),
      );

      await messenger.send({'action': 'test'});
      await messenger.dispose();
    });

    test('send serializes and sends via overlay channel', () async {
      FloatyOverlay.setUp();
      final messenger = FloatyMessenger<String>.overlay(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );

      await messenger.send('hello');
      await messenger.dispose();
      FloatyOverlay.dispose();
    });

    test('messages stream deserializes incoming data', () async {
      final messenger = FloatyMessenger<String>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as String,
      );

      final received = <String>[];
      messenger.messages.listen(received.add);

      await sendMessengerMessage('test-msg');
      expect(received, contains('test-msg'));

      await messenger.dispose();
    });

    test('messages stream forwards deserialization errors', () async {
      final messenger = FloatyMessenger<int>(
        serialize: (value) => value,
        deserialize: (raw) => raw! as int,
      );

      final errors = <Object>[];
      messenger.messages.listen((_) {}, onError: errors.add);

      await sendMessengerMessage('not-an-int');
      expect(errors, isNotEmpty);

      await messenger.dispose();
    });
  });
}
