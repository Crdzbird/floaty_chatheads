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

    test('dropOldest overflow strategy works', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final router = FloatyActionRouter.overlay(maxQueueSize: 2);
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: 'a'));
      await router.dispatch(RouterPingAction(value: 'b'));
      await router.dispatch(RouterPingAction(value: 'c'));

      expect(router.queueLength, 2);
    });

    test('dropNewest overflow strategy works', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final router = FloatyActionRouter.overlay(
        maxQueueSize: 2,
        overflowStrategy: QueueOverflowStrategy.dropNewest,
      );
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: 'a'));
      await router.dispatch(RouterPingAction(value: 'b'));
      await router.dispatch(RouterPingAction(value: 'c'));

      expect(router.queueLength, 2);
    });

    test('main app side (non-overlay) never queues', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      await router.dispatch(RouterPingAction(value: 'direct'));

      expect(router.queueLength, 0);
    });
  });
}
