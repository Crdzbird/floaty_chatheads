import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/proxy_stream_keys.dart';
import '../helpers/proxy_stream_messenger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(installProxyStreamMessenger);

  tearDown(removeProxyStreamMessenger);

  group('FloatyProxyStream multiple streams', () {
    test('two streams with different names coexist independently', () async {
      final accel = FloatyProxyStream.overlay(proxyDoubleKey('accel'));
      final light = FloatyProxyStream.overlay(proxyDoubleKey('light'));

      final accelValues = <Map<String, double>>[];
      final lightValues = <Map<String, double>>[];
      accel.stream.listen(accelValues.add);
      light.stream.listen(lightValues.add);

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'accel',
          'data': {'x': 1.0, 'y': 9.8},
        },
      });
      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'light',
          'data': {'lux': 350.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(accelValues, hasLength(1));
      expect(accelValues.first, {'x': 1.0, 'y': 9.8});
      expect(lightValues, hasLength(1));
      expect(lightValues.first, {'lux': 350.0});

      await accel.dispose();
      await light.dispose();
    });

    test('disposing one stream does not affect the other', () async {
      final stream1 = FloatyProxyStream.overlay(proxyDoubleKey('stream1'));
      final stream2 = FloatyProxyStream.overlay(proxyDoubleKey('stream2'));

      final values1 = <Map<String, double>>[];
      final values2 = <Map<String, double>>[];
      stream1.stream.listen(values1.add);
      stream2.stream.listen(values2.add);

      await stream1.dispose();

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'stream2',
          'data': {'value': 42.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values1, isEmpty);
      expect(values2, hasLength(1));
      expect(values2.first, {'value': 42.0});

      await stream2.dispose();
    });
  });
}
