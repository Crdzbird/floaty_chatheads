import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/proxy_stream_keys.dart';
import '../helpers/proxy_stream_messenger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(installProxyStreamMessenger);

  tearDown(removeProxyStreamMessenger);

  group('FloatyProxyStream (overlay side)', () {
    test('survives deserialization errors without crashing', () async {
      final proxyStream = FloatyProxyStream<Map<String, double>>.overlay(
        StreamKey<Map<String, double>>(
          name: 'gps',
          toJson: (v) => v,
          fromJson: (j) => throw const FormatException('bad data'),
        ),
      );

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      await proxyStreamSimulateIncoming({
        '__floaty__': '_floaty_pstream',
        '_floaty_pstream': {
          'name': 'gps',
          'data': {'lat': 12.0},
        },
      });

      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
      expect(proxyStream.latest, isNull);

      await proxyStream.dispose();
    });

    test('receives multiple values in order', () async {
      final proxyStream = FloatyProxyStream.overlay(proxyDoubleKey('gps'));

      final values = <Map<String, double>>[];
      proxyStream.stream.listen(values.add);

      for (var i = 0; i < 5; i++) {
        await proxyStreamSimulateIncoming({
          '__floaty__': '_floaty_pstream',
          '_floaty_pstream': {
            'name': 'gps',
            'data': {'lat': i.toDouble()},
          },
        });
      }

      await Future<void>.delayed(Duration.zero);

      expect(values, hasLength(5));
      for (var i = 0; i < 5; i++) {
        expect(values[i], {'lat': i.toDouble()});
      }
      expect(proxyStream.latest, {'lat': 4.0});

      await proxyStream.dispose();
    });
  });
}
