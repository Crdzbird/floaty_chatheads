import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';
import '../helpers/router_ping_action.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  group('FloatyActionRouter', () {
    test(
      'dispatch serializes and sends an action through the channel',
      () async {
        final router = FloatyActionRouter();
        addTearDown(router.dispose);

        await router.dispatch(RouterPingAction(value: 'hello'));
      },
    );

    test(
      'constructor registers handler on the _floaty_action prefix',
      () async {
        final router = FloatyActionRouter();
        addTearDown(router.dispose);

        final rawReceived = <Object?>[];
        FloatyChannel.rawMessages.listen(rawReceived.add);

        await deliverMessengerMessage({
          '__floaty__': '_floaty_action',
          '_floaty_action': {
            'type': 'ping',
            'payload': {'value': 'world'},
          },
        });

        expect(rawReceived, isEmpty);
      },
    );

    test('on registers a typed handler entry', () {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on(RouterPingAction.key, (_) {});
    });

    test('off removes a handler', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router
        ..on(RouterPingAction.key, (_) {})
        ..off(RouterPingAction.key);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'ignored'},
        },
      });
    });
  });
}
