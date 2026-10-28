import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/proxy_stream_keys.dart';
import '../helpers/proxy_stream_messenger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(installProxyStreamMessenger);

  tearDown(removeProxyStreamMessenger);

  group('FloatyProxyStream (overlay side)', () {
    test('receives and deserializes incoming values', () async {
      final proxyStream = FloatyProxyStream.overlay(proxyDoubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': {'lat': 12.0, 'lng': -86.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, hasLength(1));
      expect(values.first, {'lat': 12.0, 'lng': -86.0});
      expect(proxyStream.latest, {'lat': 12.0, 'lng': -86.0});

      await proxyStream.dispose();
    });

    test('ignores messages with different name', () async {
      final proxyStream = FloatyProxyStream.overlay(proxyDoubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gyroscope',
          'data': {'x': 1.0, 'y': 2.0, 'z': 3.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
      expect(proxyStream.latest, isNull);

      await proxyStream.dispose();
    });

    test('ignores messages with non-map data', () async {
      final proxyStream = FloatyProxyStream.overlay(proxyDoubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {'name': 'gps', 'data': 'not a map'},
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);

      await proxyStream.dispose();
    });
  });
}
