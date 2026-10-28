import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.reset();
  });

  group('FloatyProxyClient', () {
    test('client throws FloatyProxyTimeoutException on timeout', () async {
      final client = FloatyProxyClient(
        timeout: const Duration(milliseconds: 50),
      );

      final future = client.call('svc', 'slowMethod');

      expect(future, throwsA(isA<FloatyProxyTimeoutException>()));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      client.dispose();
    });

    test('dispose cancels pending completers with error', () async {
      final client = FloatyProxyClient(timeout: const Duration(seconds: 30));

      final future = client.call('svc', 'method');

      client.dispose();

      expect(future, throwsA(isA<FloatyProxyErrorException>()));
    });

    test('exception toString includes message', () {
      const timeout = FloatyProxyTimeoutException('svc', 'method');
      expect(timeout.toString(), contains('svc'));
      expect(timeout.toString(), contains('method'));
      expect(timeout.toString(), contains('timed out'));
      expect(timeout.message, contains('svc.method'));

      const error = FloatyProxyErrorException('Some error');
      expect(error.toString(), contains('Some error'));
      expect(error.message, 'Some error');
    });
  });
}
