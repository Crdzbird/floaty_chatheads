import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';

Map<String, Object?> _response(String id, Object? result) => {
  '__floaty__': '_floaty_proxy',
  '_floaty_proxy': {
    'id': id,
    'type': 'response',
    'result': result,
    'error': null,
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.reset();
  });

  group('FloatyProxyClient', () {
    test('multiple concurrent requests with different IDs work', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 5));

      final future0 = client.call('svc', 'method0');
      final future1 = client.call('svc', 'method1');
      final future2 = client.call('svc', 'method2');

      await deliverMessengerMessage(_response('2', 'result2'));
      await deliverMessengerMessage(_response('0', 'result0'));
      await deliverMessengerMessage(_response('1', 'result1'));

      expect(await future0, 'result0');
      expect(await future1, 'result1');
      expect(await future2, 'result2');

      client.dispose();
    });

    test('response for unknown ID is silently ignored', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 5));

      await deliverMessengerMessage(_response('nonexistent', 'orphan'));

      client.dispose();
    });

    test('ignores non-response messages', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 5));

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': '99',
          'type': 'request',
          'service': 'svc',
          'method': 'test',
          'params': <String, dynamic>{},
        },
      });

      client.dispose();
    });
  });
}
