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
        iconAsset: 'assets/icon.png',
        visibility: NotificationVisibility.visibilityPrivate,
      );
      expect(config.title, 'My Overlay');
      expect(config.iconAsset, 'assets/icon.png');
      expect(
        config.visibility,
        NotificationVisibility.visibilityPrivate,
      );
    });

    test('defaults to visibilityPublic', () {
      const config = NotificationConfig();
      expect(config.title, isNull);
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

  group('ChatHeadConfig effective getters', () {
    test('grouped assets take precedence over individual fields', () {
      const config = ChatHeadConfig(
        chatheadIconAsset: 'old_icon.png',
        closeIconAsset: 'old_close.png',
        closeBackgroundAsset: 'old_bg.png',
        assets: ChatHeadAssets(
          icon: IconSource.asset('new_icon.png'),
          closeIcon: IconSource.asset('new_close.png'),
          closeBackground: IconSource.asset('new_bg.png'),
        ),
      );

      expect(config.effectiveChatheadIcon, 'new_icon.png');
      expect(config.effectiveCloseIcon, 'new_close.png');
      expect(config.effectiveCloseBackground, 'new_bg.png');
    });

    test('individual fields used when no grouped config', () {
      const config = ChatHeadConfig(
        chatheadIconAsset: 'icon.png',
        closeIconAsset: 'close.png',
        closeBackgroundAsset: 'bg.png',
      );

      expect(config.effectiveChatheadIcon, 'icon.png');
      expect(config.effectiveCloseIcon, 'close.png');
      expect(config.effectiveCloseBackground, 'bg.png');
    });

    test('effectiveIconSource resolves network icons', () {
      const config = ChatHeadConfig(
        assets: ChatHeadAssets(
          icon: IconSource.network('https://example.com/icon.png'),
          closeIcon: IconSource.asset('close.png'),
          closeBackground: IconSource.asset('bg.png'),
        ),
      );

      expect(config.effectiveChatheadIconSource, isA<NetworkIconSource>());
      expect(
        (config.effectiveChatheadIconSource! as NetworkIconSource).url,
        'https://example.com/icon.png',
      );
      // String getter falls back to null for non-asset sources.
      expect(config.effectiveChatheadIcon, isNull);
    });

    test('effectiveIconSource wraps legacy string in AssetIconSource', () {
      const config = ChatHeadConfig(
        chatheadIconAsset: 'legacy.png',
      );

      final source = config.effectiveChatheadIconSource;
      expect(source, isA<AssetIconSource>());
      expect((source! as AssetIconSource).path, 'legacy.png');
    });

    test('grouped notification takes precedence', () {
      const config = ChatHeadConfig(
        notificationTitle: 'Old Title',
        notificationIconAsset: 'old_notif.png',
        notificationVisibility: NotificationVisibility.visibilitySecret,
        notification: NotificationConfig(
          title: 'New Title',
          iconAsset: 'new_notif.png',
          visibility: NotificationVisibility.visibilityPrivate,
        ),
      );

      expect(config.effectiveNotificationTitle, 'New Title');
      expect(config.effectiveNotificationIcon, 'new_notif.png');
      expect(
        config.effectiveNotificationVisibility,
        NotificationVisibility.visibilityPrivate,
      );
    });

    test('individual notification fields used when no grouped config', () {
      const config = ChatHeadConfig(
        notificationTitle: 'Title',
        notificationIconAsset: 'notif.png',
        notificationVisibility: NotificationVisibility.visibilitySecret,
      );

      expect(config.effectiveNotificationTitle, 'Title');
      expect(config.effectiveNotificationIcon, 'notif.png');
      expect(
        config.effectiveNotificationVisibility,
        NotificationVisibility.visibilitySecret,
      );
    });

    test('grouped snap takes precedence', () {
      const config = ChatHeadConfig(
        snapEdge: SnapEdge.left,
        snapMargin: 5,
        persistPosition: true,
        snap: SnapConfig(
          edge: SnapEdge.right,
          margin: 10,
        ),
      );

      expect(config.effectiveSnapEdge, SnapEdge.right);
      expect(config.effectiveSnapMargin, 10);
      expect(config.effectivePersistPosition, isFalse);
    });

    test('individual snap fields used when no grouped config', () {
      const config = ChatHeadConfig(
        snapEdge: SnapEdge.left,
        snapMargin: 5,
        persistPosition: true,
      );

      expect(config.effectiveSnapEdge, SnapEdge.left);
      expect(config.effectiveSnapMargin, 5);
      expect(config.effectivePersistPosition, isTrue);
    });

    test('ChatHeadAssets.defaults() resolves through effective getters', () {
      const config = ChatHeadConfig(
        assets: ChatHeadAssets.defaults(),
      );

      expect(config.effectiveChatheadIcon, 'assets/chatheadIcon.png');
      expect(config.effectiveCloseIcon, 'assets/close.png');
      expect(config.effectiveCloseBackground, 'assets/closeBg.png');
    });
  });
}
