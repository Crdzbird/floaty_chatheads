import 'package:floaty_chatheads/advanced.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/channel_test_state.dart';
import '../helpers/reset_state_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetStateChannel);

  group('FloatyStateChannel', () {
    test('setState sends a full state message through the channel', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(),
      );

      await channel.setState(ChannelTestState(count: 5, label: 'hello'));

      expect(channel.state.count, 5);
      expect(channel.state.label, 'hello');

      await channel.dispose();
    });

    test(
      'updateState sends a partial message and updates local state',
      () async {
        final channel = FloatyStateChannel<ChannelTestState>(
          toJson: (s) => s.toJson(),
          fromJson: ChannelTestState.fromJson,
          initialState: ChannelTestState(count: 1, label: 'start'),
        );

        await channel.updateState({'count': 10});

        expect(channel.state.count, 10);
        expect(channel.state.label, 'start');

        await channel.dispose();
      },
    );

    test('default constructor works for main app side', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(),
      );

      expect(channel.state.count, 0);
      await channel.dispose();
    });

    test('.overlay() constructor works for overlay side', () async {
      final channel = FloatyStateChannel<ChannelTestState>.overlay(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(count: 99, label: 'overlay'),
      );

      expect(channel.state.count, 99);
      expect(channel.state.label, 'overlay');
      await channel.dispose();
    });

    test('onStateChanged stream is broadcast', () async {
      final channel = FloatyStateChannel<ChannelTestState>(
        toJson: (s) => s.toJson(),
        fromJson: ChannelTestState.fromJson,
        initialState: ChannelTestState(),
      );

      final stream = channel.onStateChanged
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);

      await channel.dispose();
    });
  });
}
