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
    test('multiple handlers can coexist', () async {
      final stateReceived = <Map<String, dynamic>>[];
      final actionReceived = <Map<String, dynamic>>[];
      final proxyReceived = <Map<String, dynamic>>[];

      FloatyChannel.registerHandler('_floaty_state', stateReceived.add);
      FloatyChannel.registerHandler('_floaty_action', actionReceived.add);
      FloatyChannel.registerHandler('_floaty_proxy', proxyReceived.add);
      FloatyChannel.ensureListening();

      await channelSimulateMessage(
        channelSystemEnvelope('_floaty_state', {
          'full': true,
          'data': <String, dynamic>{},
        }),
      );
      await channelSimulateMessage(
        channelSystemEnvelope('_floaty_action', {
          'type': 'ping',
          'payload': <String, dynamic>{},
        }),
      );
      await channelSimulateMessage(
        channelSystemEnvelope('_floaty_proxy', {'id': '0', 'type': 'request'}),
      );

      expect(stateReceived, hasLength(1));
      expect(actionReceived, hasLength(1));
      expect(proxyReceived, hasLength(1));
    });
  });
}
