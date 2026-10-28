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

  group('FloatyProxyHost', () {
    test('returns error when handler throws', () async {
      final host = FloatyProxyHost()
        ..register('failing', (method, params) {
          throw Exception('Handler error');
        });

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': 'req-3',
          'type': 'request',
          'service': 'failing',
          'method': 'doSomething',
          'params': <String, dynamic>{},
        },
      });

      host.dispose();
    });

    test('ignores non-request messages', () async {
      final host = FloatyProxyHost();

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': 'req-4',
          'type': 'response',
          'result': null,
          'error': null,
        },
      });

      host.dispose();
    });

    test('register and unregister services', () {
      FloatyProxyHost()
        ..register('svc', (method, params) => null)
        ..unregister('svc')
        ..dispose();
    });

    test('dispose clears services and unregisters handler', () async {
      FloatyProxyHost()
        ..register('svc', (method, params) => 'result')
        ..dispose();

      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': 'req-5',
          'type': 'request',
          'service': 'svc',
          'method': 'test',
          'params': <String, dynamic>{},
        },
      });

      expect(rawReceived, hasLength(1));
    });
  });
}
