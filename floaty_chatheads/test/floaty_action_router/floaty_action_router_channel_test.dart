import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';
import '../helpers/router_ping_action.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  group('FloatyActionRouter', () {
    test('.overlay() constructor registers handler on channel', () async {
      final router = FloatyActionRouter.overlay();
      addTearDown(router.dispose);

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'from-overlay'},
        },
      });

      expect(rawReceived, isEmpty);
    });

    test('dispose clears handlers and unregisters from channel', () async {
      final router = FloatyActionRouter()..on(RouterPingAction.key, (_) {});
      await router.dispose();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'after-dispose'},
        },
      });

      expect(rawReceived, hasLength(1));
    });

    test('dispatch sends correctly formatted envelope', () async {
      final sent = <Object?>[];
      FloatyChannel.registerHandler('_floaty_action', sent.add);
      FloatyChannel.ensureListening();

      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: 'outgoing'));
    });

    test('prefixed action messages do not leak to rawMessages', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on(RouterPingAction.key, (_) {});

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'world'},
        },
      });

      await deliverMessengerMessage('raw-hello');

      expect(rawReceived, hasLength(1));
      expect(rawReceived.first, 'raw-hello');
    });
  });
}
