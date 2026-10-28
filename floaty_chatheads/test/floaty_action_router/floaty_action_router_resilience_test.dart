import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';
import '../helpers/router_navigate_action.dart';
import '../helpers/router_ping_action.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  group('FloatyActionRouter', () {
    test('unrecognized action types are silently ignored', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on(RouterPingAction.key, (_) {});

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'unknown_type',
          'payload': {'key': 'value'},
        },
      });
    });

    test('multiple handler types can be registered independently', () {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router
        ..on(RouterPingAction.key, (_) {})
        ..on(RouterNavigateAction.key, (_) {})
        ..off(RouterPingAction.key);
    });

    test('bad payload does not crash the router', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on(RouterPingAction.key, (_) {});

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {'type': 'ping', 'payload': 'not-a-map'},
      });
    });

    test('missing type field is silently ignored', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on(RouterPingAction.key, (_) {});

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'payload': {'value': 'no-type'},
        },
      });
    });

    test('fromJson throwing does not crash the router', () async {
      final router = FloatyActionRouter();
      addTearDown(router.dispose);

      router.on<RouterPingAction>(
        ActionKey<RouterPingAction>(
          'ping',
          (json) => throw const FormatException('bad data'),
        ),
        (_) {},
      );

      await deliverMessengerMessage({
        '__floaty__': '_floaty_action',
        '_floaty_action': {
          'type': 'ping',
          'payload': {'value': 'will-fail-parse'},
        },
      });
    });
  });
}
