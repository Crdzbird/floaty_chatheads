import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/kit_increment_action.dart';
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

    test('onAction/offAction delegates to router', () async {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      var received = false;
      kit.onAction(KitIncrementAction.key, (_) => received = true);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 1},
        },
      });

      expect(received, isTrue);

      kit.offAction(KitIncrementAction.key);
      received = false;

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 2},
        },
      });

      expect(received, isFalse);
    });

    test('dispose tears down all overlay components', () async {
      await FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      ).dispose();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 1},
        },
      });

      expect(rawReceived, hasLength(1));
    });
  });
}
