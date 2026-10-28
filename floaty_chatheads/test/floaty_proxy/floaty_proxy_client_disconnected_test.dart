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

    test(
      'call throws FloatyProxyDisconnectedException when disconnected',
      () async {
        await deliverMessengerMessage({
          '__floaty__': '_floaty_connection',
          '_floaty_connection': {'connected': false},
        });

        final client = FloatyProxyClient(timeout: const Duration(seconds: 5));
        addTearDown(client.dispose);

        expect(
          client.call('svc', 'method'),
          throwsA(isA<FloatyProxyDisconnectedException>()),
        );
      },
    );

    test(
      'call returns fallback when disconnected and fallback provided',
      () async {
        await deliverMessengerMessage({
          '__floaty__': '_floaty_connection',
          '_floaty_connection': {'connected': false},
        });

        final client = FloatyProxyClient(timeout: const Duration(seconds: 5));
        addTearDown(client.dispose);

        final result = await client.call(
          'svc',
          'method',
          fallback: () => 'default-value',
        );

        expect(result, 'default-value');
      },
    );
  });
}
