import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/kit_test_state.dart';
import '../helpers/messenger_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  group('FloatyOverlayKit', () {
    setUp(() {
      FloatyConnectionState.dispose();
      FloatyConnectionState.setUp();
    });

    tearDown(FloatyConnectionState.dispose);

    test('state and onStateChanged delegate correctly', () async {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.state.counter, 0);

      final states = <KitTestState>[];
      kit.onStateChanged.listen(states.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'counter': 99, 'label': 'synced'},
        },
      });

      expect(states, hasLength(1));
      expect(states.first.counter, 99);
      expect(kit.state.counter, 99);
    });

    test('setState delegates to stateChannel', () async {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.state.counter, 0);

      await kit.setState(KitTestState(counter: 42, label: 'updated'));

      expect(kit.state.counter, 42);
      expect(kit.state.label, 'updated');
    });

    test('updateState performs shallow merge', () async {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      await kit.setState(KitTestState(counter: 10, label: 'before'));
      await kit.updateState({'counter': 20});

      expect(kit.state.counter, 20);
      expect(kit.state.label, 'before');
    });
  });
}
