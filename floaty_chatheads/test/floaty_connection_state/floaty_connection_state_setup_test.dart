import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/reset_connection_state.dart';
import '../helpers/send_messenger_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetConnectionState);

  tearDown(resetConnectionState);

  group('FloatyConnectionState', () {
    test('setUp registers handler and enables listening', () async {
      FloatyConnectionState.setUp();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });

      expect(rawReceived, isEmpty);
    });

    test('isMainAppConnected defaults to true', () {
      expect(FloatyConnectionState.isMainAppConnected, isTrue);
    });

    test('dispose resets state', () async {
      FloatyConnectionState.setUp();

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(FloatyConnectionState.isMainAppConnected, isFalse);

      FloatyConnectionState.dispose();

      expect(FloatyConnectionState.isMainAppConnected, isTrue);
    });

    test('setUp is idempotent (safe to call multiple times)', () async {
      FloatyConnectionState.setUp();
      FloatyConnectionState.setUp();
      FloatyConnectionState.setUp();

      final emissions = <bool>[];
      FloatyConnectionState.onConnectionChanged.listen(emissions.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(emissions, [false]);
    });
  });
}
