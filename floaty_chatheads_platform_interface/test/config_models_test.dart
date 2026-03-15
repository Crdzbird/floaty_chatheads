import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHeadAssets', () {
    test('constructor stores all fields', () {
      const assets = ChatHeadAssets(
        icon: 'a.png',
        closeIcon: 'b.png',
        closeBackground: 'c.png',
      );
      expect(assets.icon, 'a.png');
      expect(assets.closeIcon, 'b.png');
      expect(assets.closeBackground, 'c.png');
    });

    test('defaults() uses convention-based names', () {
      const assets = ChatHeadAssets.defaults();
      expect(assets.icon, 'assets/chatheadIcon.png');
      expect(assets.closeIcon, 'assets/close.png');
      expect(assets.closeBackground, 'assets/closeBg.png');
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
          icon: 'new_icon.png',
          closeIcon: 'new_close.png',
          closeBackground: 'new_bg.png',
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
