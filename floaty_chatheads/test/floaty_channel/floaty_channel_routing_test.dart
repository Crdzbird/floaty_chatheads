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
      'messages with _floaty_state prefix are routed to registered handler',
      () async {
        final received = <Map<String, dynamic>>[];
        FloatyChannel.registerHandler('_floaty_state', received.add);
        FloatyChannel.ensureListening();

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_state', {
            'full': true,
            'data': {'count': 1},
          }),
        );

        expect(received, hasLength(1));
        expect(received.first['full'], true);
        expect(rawReceived, isEmpty);
      },
    );

    test(
      'messages with _floaty_action prefix are routed to registered handler',
      () async {
        final received = <Map<String, dynamic>>[];
        FloatyChannel.registerHandler('_floaty_action', received.add);
        FloatyChannel.ensureListening();

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_action', {
            'type': 'ping',
            'payload': <String, dynamic>{},
          }),
        );

        expect(received, hasLength(1));
        expect(received.first['type'], 'ping');
        expect(rawReceived, isEmpty);
      },
    );

    test(
      'messages with _floaty_proxy prefix are routed to registered handler',
      () async {
        final received = <Map<String, dynamic>>[];
        FloatyChannel.registerHandler('_floaty_proxy', received.add);
        FloatyChannel.ensureListening();

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await channelSimulateMessage(
          channelSystemEnvelope('_floaty_proxy', {
            'id': '0',
            'type': 'request',
          }),
        );

        expect(received, hasLength(1));
        expect(received.first['type'], 'request');
        expect(rawReceived, isEmpty);
      },
    );
  });
}
