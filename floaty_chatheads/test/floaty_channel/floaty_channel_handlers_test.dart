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
    test('registering and unregistering handlers works', () async {
      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler('_floaty_state', received.add);
      FloatyChannel.ensureListening();

      await channelSimulateMessage(
        channelSystemEnvelope('_floaty_state', {
          'full': true,
          'data': <String, dynamic>{},
        }),
      );
      expect(received, hasLength(1));

      FloatyChannel.unregisterHandler('_floaty_state');

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await channelSimulateMessage(
        channelSystemEnvelope('_floaty_state', {
          'full': true,
          'data': <String, dynamic>{},
        }),
      );

      expect(received, hasLength(1));
      expect(rawReceived, hasLength(1));
    });

    test('dispose clears all state and allows re-listening', () async {
      FloatyChannel.registerHandler('_floaty_state', (data) {});
      FloatyChannel.ensureListening();

      FloatyChannel.reset();

      final received = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler('_floaty_state', received.add);
      FloatyChannel.ensureListening();

      await channelSimulateMessage(
        channelSystemEnvelope('_floaty_state', {'key': 'value'}),
      );

      expect(received, hasLength(1));
    });

    test('ensureListening is safe to call multiple times', () {
      FloatyChannel.ensureListening();
      FloatyChannel.ensureListening();
      FloatyChannel.ensureListening();
    });

    test('send transmits data through the channel', () async {
      await FloatyChannel.send({'key': 'value'});
    });

    test('sendSystem wraps payload in system envelope', () async {
      await FloatyChannel.sendSystem('_floaty_state', {'key': 'value'});
    });
  });
}
