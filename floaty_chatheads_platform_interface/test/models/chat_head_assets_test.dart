import 'dart:typed_data';

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHeadAssets', () {
    test('constructor stores all fields', () {
      const assets = ChatHeadAssets(
        icon: IconSource.asset('a.png'),
        closeIcon: IconSource.asset('b.png'),
        closeBackground: IconSource.asset('c.png'),
      );
      expect((assets.icon as AssetIconSource).path, 'a.png');
      expect((assets.closeIcon as AssetIconSource).path, 'b.png');
      expect((assets.closeBackground as AssetIconSource).path, 'c.png');
    });

    test('constructor accepts mixed icon sources', () {
      final assets = ChatHeadAssets(
        icon: const IconSource.network('https://example.com/icon.png'),
        closeIcon: const IconSource.asset('assets/close.png'),
        closeBackground: IconSource.bytes(Uint8List.fromList([1, 2, 3])),
      );
      expect(assets.icon, isA<NetworkIconSource>());
      expect(assets.closeIcon, isA<AssetIconSource>());
      expect(assets.closeBackground, isA<BytesIconSource>());
    });

    test('defaults() uses convention-based asset names', () {
      const assets = ChatHeadAssets.defaults();
      expect((assets.icon as AssetIconSource).path, 'assets/chatheadIcon.png');
      expect((assets.closeIcon as AssetIconSource).path, 'assets/close.png');
      expect(
        (assets.closeBackground as AssetIconSource).path,
        'assets/closeBg.png',
      );
    });
  });
}
