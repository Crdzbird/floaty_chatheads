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

  group('FloatyProxyClient', () {
    test('client resolves when a matching response arrives', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 5));

      final future = client.call('location', 'getPosition');

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': '0',
          'type': 'response',
          'result': {'lat': 12.0, 'lng': -86.0},
          'error': null,
        },
      });

      final result = await future;
      expect(result, isA<Map<dynamic, dynamic>>());
      final map = result! as Map<dynamic, dynamic>;
      expect(map['lat'], 12.0);
      expect(map['lng'], -86.0);

      client.dispose();
    });

    test('client throws FloatyProxyErrorException on error response', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 5));

      final future = client.call('svc', 'method');

      final errorFuture = expectLater(
        future,
        throwsA(isA<FloatyProxyErrorException>()),
      );

      await deliverMessengerMessage({
        '__floaty__': '_floaty_proxy',
        '_floaty_proxy': {
          'id': '0',
          'type': 'response',
          'result': null,
          'error': 'Something went wrong',
        },
      });

      await errorFuture;

      client.dispose();
    });
  });
}
