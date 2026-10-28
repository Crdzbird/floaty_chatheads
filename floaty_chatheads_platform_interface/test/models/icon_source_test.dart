import 'dart:typed_data';

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IconSource', () {
    test('asset factory stores path', () {
      const source = IconSource.asset('assets/icon.png');
      expect(source, isA<AssetIconSource>());
      expect((source as AssetIconSource).path, 'assets/icon.png');
    });

    test('network factory stores url', () {
      const source = IconSource.network('https://example.com/icon.png');
      expect(source, isA<NetworkIconSource>());
      expect((source as NetworkIconSource).url, 'https://example.com/icon.png');
    });

    test('bytes factory stores data', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final source = IconSource.bytes(data);
      expect(source, isA<BytesIconSource>());
      expect((source as BytesIconSource).data, data);
    });
  });
}
