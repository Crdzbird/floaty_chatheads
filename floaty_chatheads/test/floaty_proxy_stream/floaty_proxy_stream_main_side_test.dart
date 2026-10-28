import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/proxy_stream_keys.dart';
import '../helpers/proxy_stream_messenger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Object?> sentMessages;

  setUp(() {
    sentMessages = installProxyStreamMessenger();
  });

  tearDown(removeProxyStreamMessenger);

  group('FloatyProxyStream (main app side)', () {
    test('add() sends system message with name and serialized data', () async {
      final stream = FloatyProxyStream(proxyDoubleKey('gps'));

      await stream.add({'lat': 12.0, 'lng': -86.0});

      expect(sentMessages, hasLength(1));
      final msg = sentMessages.first! as Map;
      expect(msg['__floaty__'], '_floaty_pstream');
      expect(msg['_floaty_pstream'], {
        'name': 'gps',
        'data': {'lat': 12.0, 'lng': -86.0},
      });

      await stream.dispose();
    });

    test('add() updates latest and emits on stream', () async {
      final proxyStream = FloatyProxyStream(proxyIntKey('counter'));

      expect(proxyStream.latest, isNull);

      final values = <Map<String, int>>[];
      proxyStream.stream.listen(values.add);

      await proxyStream.add({'value': 1});
      await proxyStream.add({'value': 2});

      expect(proxyStream.latest, {'value': 2});
      expect(values, [
        {'value': 1},
        {'value': 2},
      ]);

      await proxyStream.dispose();
    });

    test('add() is a no-op on overlay-side instance', () async {
      final proxyStream = FloatyProxyStream.overlay(proxyIntKey('test'));

      await proxyStream.add({'value': 1});

      expect(sentMessages, isEmpty);
      expect(proxyStream.latest, isNull);

      await proxyStream.dispose();
    });
  });
}
