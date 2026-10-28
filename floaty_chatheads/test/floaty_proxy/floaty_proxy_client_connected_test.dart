import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.reset();
  });

  group('FloatyProxyClient disconnection behavior', () {
    setUp(() {
      FloatyConnectionState.dispose();
      FloatyConnectionState.setUp();
    });

    tearDown(FloatyConnectionState.dispose);

    test('call works normally when connected', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 5));
      addTearDown(client.dispose);

      final future = client.call('svc', 'method');

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': '0',
          'type': 'response',
          'result': 'connected-result',
          'error': null,
        },
      });

      final result = await future;
      expect(result, 'connected-result');
    });

    test('FloatyProxyDisconnectedException toString includes service '
        'and method', () {
      const ex = FloatyProxyDisconnectedException('loc', 'getPos');
      expect(ex.toString(), contains('loc'));
      expect(ex.toString(), contains('getPos'));
      expect(ex.toString(), contains('disconnected'));
    });
  });
}
