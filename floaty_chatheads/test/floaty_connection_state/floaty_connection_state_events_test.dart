import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/reset_connection_state.dart';
import '../helpers/send_messenger_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetConnectionState);

  tearDown(resetConnectionState);

  group('FloatyConnectionState', () {
    test('receiving {"connected": false} updates state and emits on '
        'stream', () async {
      FloatyConnectionState.setUp();

      final emissions = <bool>[];
      FloatyConnectionState.onConnectionChanged.listen(emissions.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(FloatyConnectionState.isMainAppConnected, isFalse);
      expect(emissions, [false]);
    });

    test('receiving {"connected": true} updates state and emits on '
        'stream', () async {
      FloatyConnectionState.setUp();

      final emissions = <bool>[];
      FloatyConnectionState.onConnectionChanged.listen(emissions.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });

      expect(FloatyConnectionState.isMainAppConnected, isTrue);
      expect(emissions, [false, true]);
    });

    test('duplicate values do not emit', () async {
      FloatyConnectionState.setUp();

      final emissions = <bool>[];
      FloatyConnectionState.onConnectionChanged.listen(emissions.add);

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });

      expect(emissions, isEmpty);

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      await sendMessengerMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });

      expect(emissions, [false]);
    });
  });
}
