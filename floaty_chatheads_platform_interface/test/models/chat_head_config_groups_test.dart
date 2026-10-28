import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHeadConfig grouped configs', () {
    test('assets are stored correctly', () {
      const config = ChatHeadConfig(
        assets: ChatHeadAssets(
          icon: IconSource.asset('new_icon.png'),
          closeIcon: IconSource.asset('new_close.png'),
          closeBackground: IconSource.asset('new_bg.png'),
        ),
      );

      expect((config.assets!.icon as AssetIconSource).path, 'new_icon.png');
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
        snap: SnapConfig(edge: SnapEdge.right, margin: 10),
      );

      expect(config.snap!.edge, SnapEdge.right);
      expect(config.snap!.margin, 10);
      expect(config.snap!.persistPosition, isFalse);
    });

    test('ChatHeadAssets.defaults() resolves correctly', () {
      const config = ChatHeadConfig(assets: ChatHeadAssets.defaults());

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
}
