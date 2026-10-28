import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/channel_test_messages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.reset();
  });

  group('FloatyChannel', () {
    test(
      'raw messages without a prefix are forwarded to rawMessages stream',
      () async {
        FloatyChannel.ensureListening();

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await channelSimulateMessage({'action': 'test', 'value': 42});

        expect(rawReceived, hasLength(1));
        expect(rawReceived.first, isA<Map<dynamic, dynamic>>());
      },
    );

    test('non-Map messages go to raw stream', () async {
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await channelSimulateMessage('just a string');

      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, 'just a string');
    });

    test('null messages go to raw stream', () async {
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await channelSimulateMessage(null);

      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, isNull);
    });

    test('map with prefix key but non-map value goes to raw stream', () async {
      FloatyChannel.registerHandler('_floaty_state', (_) {});
      FloatyChannel.ensureListening();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await channelSimulateMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': 'not-a-map',
      });

      expect(rawReceived, hasLength(1));
    });

    test(
      'map without system envelope goes to raw stream even with prefix key',
      () async {
        FloatyChannel.registerHandler('_floaty_state', (_) {});
        FloatyChannel.ensureListening();

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await channelSimulateMessage({
          '_floaty_state': {'full': true},
        });

        expect(rawReceived, hasLength(1));
      },
    );
  });
}
