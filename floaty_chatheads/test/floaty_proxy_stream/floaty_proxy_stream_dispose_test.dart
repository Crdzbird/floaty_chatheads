import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/proxy_stream_keys.dart';
import '../helpers/proxy_stream_messenger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(installProxyStreamMessenger);

  tearDown(removeProxyStreamMessenger);

  group('FloatyProxyStream duplicate name', () {
    test('throws StateError when registering a duplicate name', () async {
      final first = FloatyProxyStream(proxyDoubleKey('dup'));

      expect(() => FloatyProxyStream(proxyDoubleKey('dup')), throwsStateError);

      await first.dispose();
    });

    test('allows re-registration after dispose', () async {
      final first = FloatyProxyStream(proxyDoubleKey('reuse'));
      await first.dispose();
      expect(first, isNotNull);
      final second = FloatyProxyStream(proxyDoubleKey('reuse'));
      await second.dispose();
      expect(second, isNotNull);
    });
  });

  group('FloatyProxyStream dispose', () {
    test('dispose unregisters handler', () async {
      final proxyStream = FloatyProxyStream.overlay(proxyDoubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await proxyStream.dispose();

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': {'lat': 99.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
    });
  });
}
