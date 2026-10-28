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
    test('responds to a request with the handler result', () async {
      final host = FloatyProxyHost()
        ..register('location', (method, params) async {
          if (method == 'getPosition') {
            return {'lat': 12.0, 'lng': -86.0};
          }
          return null;
        });

      final responses = <Map<String, dynamic>>[];
      FloatyChannel.registerHandler('_floaty_proxy', responses.add);

      FloatyChannel.reset();
      final host2 = FloatyProxyHost()
        ..register('math', (method, params) async {
          if (method == 'add') {
            final a = params['a'] as int;
            final b = params['b'] as int;
            return {'sum': a + b};
          }
          return null;
        });

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': 'req-1',
          'type': 'request',
          'service': 'math',
          'method': 'add',
          'params': {'a': 3, 'b': 4},
        },
      });

      host.dispose();
      host2.dispose();
    });

    test('returns error for unknown service', () async {
      final host = FloatyProxyHost();

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': 'req-2',
          'type': 'request',
          'service': 'nonexistent',
          'method': 'doSomething',
          'params': <String, dynamic>{},
        },
      });

      host.dispose();
    });
  });
}
