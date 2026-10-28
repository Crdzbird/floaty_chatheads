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
      'messages for never-registered prefix are buffered and replayed',
      () async {
        FloatyChannel.ensureListening();

        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_new', {'seq': 1}),
        );
        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_new', {'seq': 2}),
        );

        final received = <Map<String, dynamic>>[];
        FloatyChannel.registerHandler('_floaty_new', received.add);

        expect(received, hasLength(2));
        expect(received[0]['seq'], 1);
        expect(received[1]['seq'], 2);

        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_new', {'seq': 3}),
        );
        expect(received, hasLength(3));
        expect(received[2]['seq'], 3);
      },
    );

    test('buffered messages respect _maxPendingPerPrefix limit', () async {
      FloatyChannel.ensureListening();

      for (var i = 0; i < 210; i++) {
        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_overflow', {'i': i}),
        );
      }

      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler('_floaty_overflow', received.add);

      expect(received, hasLength(200));
      expect(received.first['i'], 0);
      expect(received.last['i'], 199);
    });

    test(
      'no buffering for previously-registered-then-removed prefix',
      () async {
        FloatyChannel.registerHandler('_floaty_temp', (_) {});
        FloatyChannel.unregisterHandler('_floaty_temp');
        FloatyChannel.ensureListening();

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_temp', {'key': 'val'}),
        );
        expect(rawReceived, hasLength(1));

        final received = <Map<String, dynamic>>[];
        FloatyChannel.registerHandler('_floaty_temp', received.add);
        expect(received, isEmpty);
      },
    );
  });
}
