import 'package:floaty_chatheads/advanced.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/channel_test_state.dart';
import '../helpers/reset_state_channel.dart';
import '../helpers/send_messenger_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetStateChannel);

  group('FloatyStateChannel', () {
    test('receiving a full state updates the state getter', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(),
      );

      await sendMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'count': 42, 'label': 'received'},
        },
      });

      expect(channel.state.count, 42);
      expect(channel.state.label, 'received');

      await channel.dispose();
    });

    test(
      'receiving a partial state merges correctly (shallow merge)',
      () async {
        final channel = FloatyStateChannel<ChannelTestState>(
          toJson: (s) => s.toJson(),
          fromJson: ChannelTestState.fromJson,
          initialState: ChannelTestState(count: 5, label: 'original'),
        );

        await sendMessengerMessage({
          '__floaty__': '_floaty_state',
          '_floaty_state': {
            'full': false,
            'data': {'label': 'updated'},
          },
        });

        expect(channel.state.count, 5);
        expect(channel.state.label, 'updated');

        await channel.dispose();
      },
    );

    test('onStateChanged stream emits on changes', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(),
      );

      final states = <ChannelTestState>[];
      channel.onStateChanged.listen(states.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'count': 1, 'label': 'first'},
        },
      });

      await sendMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'count': 2, 'label': 'second'},
        },
      });

      expect(states, hasLength(2));
      expect(states[0].count, 1);
      expect(states[1].count, 2);

      await channel.dispose();
    });
  });
}
