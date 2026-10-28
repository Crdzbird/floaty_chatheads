import 'package:floaty_chatheads/advanced.dart';
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

    test('constructor creates all components', () {
      expect(kit.router, isA<FloatyActionRouter>());
      expect(kit.stateChannel, isA<FloatyStateChannel<KitTestState>>());
      expect(kit.proxyHost, isA<FloatyProxyHost>());
    });

    test('onAction/offAction delegates to router', () async {
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

    test('setState/state delegates to stateChannel', () async {
      expect(kit.state.counter, 0);

      await kit.setState(KitTestState(counter: 42, label: 'updated'));

      expect(kit.state.counter, 42);
      expect(kit.state.label, 'updated');
    });

    test('onStateChanged emits on remote update', () async {
      final states = <KitTestState>[];
      kit.onStateChanged.listen(states.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'counter': 7, 'label': 'remote'},
        },
      });

      expect(states, hasLength(1));
      expect(states.first.counter, 7);
    });
  });
}
