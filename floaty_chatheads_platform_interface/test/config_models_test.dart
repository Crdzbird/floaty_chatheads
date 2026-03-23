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
      expect(
        (assets.icon as AssetIconSource).path,
        'assets/chatheadIcon.png',
      );
      expect(
        (assets.closeIcon as AssetIconSource).path,
        'assets/close.png',
      );
      expect(
        (assets.closeBackground as AssetIconSource).path,
        'assets/closeBg.png',
      );
    });
  });

  group('NotificationConfig', () {
    test('constructor stores all fields', () {
      const config = NotificationConfig(
        title: 'My Overlay',
        description: 'Overlay is active',
        iconAsset: 'assets/icon.png',
        visibility: NotificationVisibility.visibilityPrivate,
      );
      expect(config.title, 'My Overlay');
      expect(config.description, 'Overlay is active');
      expect(config.iconAsset, 'assets/icon.png');
      expect(
        config.visibility,
        NotificationVisibility.visibilityPrivate,
      );
    });

    test('defaults to visibilityPublic and null description', () {
      const config = NotificationConfig();
      expect(config.title, isNull);
      expect(config.description, isNull);
      expect(config.iconAsset, isNull);
      expect(
        config.visibility,
        NotificationVisibility.visibilityPublic,
      );
    });
  });

  group('SnapConfig', () {
    test('constructor stores all fields', () {
      const config = SnapConfig(
        edge: SnapEdge.left,
        margin: 5,
        persistPosition: true,
      );
      expect(config.edge, SnapEdge.left);
      expect(config.margin, 5);
      expect(config.persistPosition, isTrue);
    });

    test('defaults to both / -10 / false', () {
      const config = SnapConfig();
      expect(config.edge, SnapEdge.both);
      expect(config.margin, -10);
      expect(config.persistPosition, isFalse);
    });
  });

  group('ChatHeadConfig grouped configs', () {
    test('assets are stored correctly', () {
      const config = ChatHeadConfig(
        assets: ChatHeadAssets(
          icon: IconSource.asset('new_icon.png'),
          closeIcon: IconSource.asset('new_close.png'),
          closeBackground: IconSource.asset('new_bg.png'),
        ),
      );

      expect(
        (config.assets!.icon as AssetIconSource).path,
        'new_icon.png',
      );
      expect(
        (config.assets!.closeIcon as AssetIconSource).path,
        'new_close.png',
      );
      expect(
        (config.assets!.closeBackground as AssetIconSource).path,
        'new_bg.png',
      );
    });

    test('assets support network icons', () {
      const config = ChatHeadConfig(
        assets: ChatHeadAssets(
          icon: IconSource.network('https://example.com/icon.png'),
          closeIcon: IconSource.asset('close.png'),
          closeBackground: IconSource.asset('bg.png'),
        ),
      );

      expect(config.assets!.icon, isA<NetworkIconSource>());
      expect(
        (config.assets!.icon as NetworkIconSource).url,
        'https://example.com/icon.png',
      );
    });

    test('notification config is stored correctly', () {
      const config = ChatHeadConfig(
        notification: NotificationConfig(
          title: 'New Title',
          description: 'New Body',
          iconAsset: 'new_notif.png',
          visibility: NotificationVisibility.visibilityPrivate,
        ),
      );

      expect(config.notification!.title, 'New Title');
      expect(config.notification!.description, 'New Body');
      expect(config.notification!.iconAsset, 'new_notif.png');
      expect(
        config.notification!.visibility,
        NotificationVisibility.visibilityPrivate,
      );
    });

    test('snap config is stored correctly', () {
      const config = ChatHeadConfig(
        snap: SnapConfig(
          edge: SnapEdge.right,
          margin: 10,
        ),
      );

      expect(config.snap!.edge, SnapEdge.right);
      expect(config.snap!.margin, 10);
      expect(config.snap!.persistPosition, isFalse);
    });

    test('ChatHeadAssets.defaults() resolves correctly', () {
      const config = ChatHeadConfig(
        assets: ChatHeadAssets.defaults(),
      );

      expect(
        (config.assets!.icon as AssetIconSource).path,
        'assets/chatheadIcon.png',
      );
      expect(
        (config.assets!.closeIcon as AssetIconSource).path,
        'assets/close.png',
      );
      expect(
        (config.assets!.closeBackground as AssetIconSource).path,
        'assets/closeBg.png',
      );
    });

    test('defaults have null grouped configs', () {
      const config = ChatHeadConfig();
      expect(config.assets, isNull);
      expect(config.notification, isNull);
      expect(config.snap, isNull);
    });
  });

  group('ChatHeadTheme', () {
    test('equality uses map content, not identity', () {
      const a = ChatHeadTheme(
        badgeColor: 0xFFFF0000,
        overlayPalette: {'primary': 0xFF000000, 'surface': 0xFFFFFFFF},
      );
      const b = ChatHeadTheme(
        badgeColor: 0xFFFF0000,
        overlayPalette: {'primary': 0xFF000000, 'surface': 0xFFFFFFFF},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode is order-independent for overlayPalette', () {
      // Two maps with identical content but different insertion order.
      final palette1 = <String, int>{}
        ..['primary'] = 0xFF000000
        ..['surface'] = 0xFFFFFFFF
        ..['error'] = 0xFFFF0000;
      final palette2 = <String, int>{}
        ..['error'] = 0xFFFF0000
        ..['surface'] = 0xFFFFFFFF
        ..['primary'] = 0xFF000000;

      final a = ChatHeadTheme(overlayPalette: palette1);
      final b = ChatHeadTheme(overlayPalette: palette2);

      expect(a, equals(b));
      expect(
        a.hashCode,
        equals(b.hashCode),
        reason: 'hashCode must be order-independent for equal maps',
      );
    });

    test('null overlayPalette produces consistent hash', () {
      const a = ChatHeadTheme(badgeColor: 0xFF00FF00);
      const b = ChatHeadTheme(badgeColor: 0xFF00FF00);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different overlayPalette values produce different hashes', () {
      const a = ChatHeadTheme(
        overlayPalette: {'primary': 0xFF000000},
      );
      const b = ChatHeadTheme(
        overlayPalette: {'primary': 0xFFFFFFFF},
      );
      expect(a, isNot(equals(b)));
      // Hash collision is theoretically possible but extremely unlikely.
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
