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

  group('FloatyOverlayKit', () {
    setUp(() {
      FloatyConnectionState.dispose();
      FloatyConnectionState.setUp();
    });

    tearDown(FloatyConnectionState.dispose);

    test('dispatch queues when disconnected', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      await kit.dispatch(KitIncrementAction(amount: 1));
      await kit.dispatch(KitIncrementAction(amount: 2));

      expect(kit.queueLength, 2);
    });

    test('callService returns fallback when disconnected', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      final result = await kit.callService(
        'time',
        'now',
        fallback: () => 'offline',
      );

      expect(result, 'offline');
    });

    test('callService throws when disconnected without fallback', () async {
      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      expect(
        () => kit.callService('time', 'now'),
        throwsA(isA<FloatyProxyDisconnectedException>()),
      );
    });
  });
}
