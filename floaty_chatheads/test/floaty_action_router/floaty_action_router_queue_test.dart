import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';
import '../helpers/router_ping_action.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  group('FloatyActionRouter queue behavior', () {
    setUp(() {
      FloatyConnectionState.dispose();
      FloatyConnectionState.setUp();
    });

    tearDown(FloatyConnectionState.dispose);

    test('dispatch queues actions when overlay is disconnected', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final router = FloatyActionRouter.overlay();
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: 'queued'));

      expect(router.queueLength, 1);
    });

    test('queueLength reflects queued actions', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final router = FloatyActionRouter.overlay();
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: 'a'));
      await router.dispatch(RouterPingAction(value: 'b'));
      await router.dispatch(RouterPingAction(value: 'c'));

      expect(router.queueLength, 3);
    });

    test('actions are flushed in order on reconnection', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final router = FloatyActionRouter.overlay();
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: '1'));
      await router.dispatch(RouterPingAction(value: '2'));
      await router.dispatch(RouterPingAction(value: '3'));

      expect(router.queueLength, 3);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });

      expect(router.queueLength, 0);
    });
  });
}
