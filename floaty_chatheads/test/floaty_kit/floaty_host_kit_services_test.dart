import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/kit_increment_action.dart';
import '../helpers/kit_test_state.dart';
import '../helpers/messenger_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  group('FloatyHostKit', () {
    late FloatyHostKit<KitTestState> kit;

    setUp(() {
      kit = FloatyHostKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
    });

    tearDown(() => kit.dispose());

    test('updateState performs shallow merge', () async {
      await kit.setState(KitTestState(counter: 10, label: 'before'));
      await kit.updateState({'counter': 20});

      expect(kit.state.counter, 20);
      expect(kit.state.label, 'before');
    });

    test('registerService handles proxy requests', () async {
      kit.registerService('echo', (method, params) {
        return {'echoed': method};
      });

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'type': 'request',
          'id': '42',
          'service': 'echo',
          'method': 'ping',
          'params': <String, dynamic>{},
        },
      });
    });

    test('unregisterService removes service', () {
      kit
        ..registerService('temp', (_, _) => null)
        ..unregisterService('temp');
    });

    test('dispatch does not throw', () async {
      await kit.dispatch(KitIncrementAction(amount: 5));
    });

    test('queueLength is always 0 on host side', () async {
      expect(kit.queueLength, 0);
      await kit.dispatch(KitIncrementAction(amount: 1));
      expect(kit.queueLength, 0);
    });

    test('dispose tears down all components', () async {
      await kit.dispose();

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
