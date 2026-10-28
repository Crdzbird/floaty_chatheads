import 'package:floaty_chatheads/advanced.dart';
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

    test('constructor creates overlay-side components', () {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.router, isA<FloatyActionRouter>());
      expect(kit.stateChannel, isA<FloatyStateChannel<KitTestState>>());
      expect(kit.proxyClient, isA<FloatyProxyClient>());
    });

    test('isConnected delegates to FloatyConnectionState', () async {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.isConnected, isTrue);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(kit.isConnected, isFalse);
    });

    test('onConnectionChanged emits on state change', () async {
      final kit = FloatyOverlayKit<KitTestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: KitTestState.fromJson,
        initialState: KitTestState(),
      );
      addTearDown(kit.dispose);

      final events = <bool>[];
      kit.onConnectionChanged.listen(events.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(events, contains(false));
    });
  });
}
