import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/channel_test_state.dart';
import '../helpers/reset_state_channel.dart';
import '../helpers/send_messenger_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetStateChannel);

  group('FloatyStateChannel', () {
    test('dispose unregisters the handler', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(),
      );
      await channel.dispose();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'count': 99, 'label': 'after-dispose'},
        },
      });

      expect(rawReceived, hasLength(1));
      expect(channel.state.count, 0);
    });

    test('receiving message with non-map data is silently ignored', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(count: 7, label: 'stable'),
      );

      final states = <ChannelTestState>[];
      channel.onStateChanged.listen(states.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {'full': true, 'data': 'not-a-map'},
      });

      expect(states, isEmpty);
      expect(channel.state.count, 7);

      await channel.dispose();
    });
  });
}
