import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Floaty', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('show checks permission and shows chathead', () async {
      final result = await Floaty.show(
        entryPoint: 'testOverlay',
        assets: const ChatHeadAssets(
          icon: IconSource.asset('assets/icon.png'),
          closeIcon: IconSource.asset('assets/close.png'),
          closeBackground: IconSource.asset('assets/closeBg.png'),
        ),
      );
      expect(result, isTrue);
      expect(fake.checkPermissionCalled, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('testOverlay'));
      expect(
        (fake.lastConfig?.assets?.icon as AssetIconSource?)?.path,
        equals('assets/icon.png'),
      );
    });

    test('show requests permission when not granted', () async {
      fake.permissionGranted = false;
      final result = await Floaty.show();
      expect(result, isFalse);
      expect(fake.checkPermissionCalled, isTrue);
      expect(fake.requestPermissionCalled, isTrue);
      expect(fake.showChatHeadCalled, isFalse);
    });

    test('ensurePermission short-circuits when already granted', () async {
      expect(await Floaty.ensurePermission(), isTrue);
      expect(fake.requestPermissionCalled, isFalse);
    });

    test('show defaults to the card preset and the below anchor', () async {
      await Floaty.show();
      expect(fake.lastConfig?.sizePreset, equals(ContentSizePreset.card));
      expect(fake.lastConfig?.panelAnchor, equals(PanelAnchor.below));
    });

    test('show passes a named size preset', () async {
      await Floaty.show(size: ContentSizePreset.halfScreen);
      expect(
        fake.lastConfig?.sizePreset,
        equals(ContentSizePreset.halfScreen),
      );
    });

    test('explicit dimensions replace the size preset', () async {
      await Floaty.show(contentWidth: 320, contentHeight: 480);
      expect(fake.lastConfig?.sizePreset, isNull);
      expect(fake.lastConfig?.contentWidth, equals(320));
      expect(fake.lastConfig?.contentHeight, equals(480));
    });

    test('title becomes the notification title', () async {
      await Floaty.show(title: 'My App');
      expect(fake.lastConfig?.notification?.title, equals('My App'));
    });

    test('an explicit notification wins over title', () async {
      await Floaty.show(
        title: 'ignored',
        notification: const NotificationConfig(title: 'explicit'),
      );
      expect(fake.lastConfig?.notification?.title, equals('explicit'));
    });

    test('show passes the full option surface', () async {
      const theme = ChatHeadTheme(badgeColor: 0xFFFF0000);
      await Floaty.show(
        theme: theme,
        panelAnchor: PanelAnchor.auto,
        autoLaunchOnBackground: true,
        persistOnAppClose: true,
        debugMode: true,
        enableDrag: false,
        flag: OverlayFlag.clickThrough,
        snap: const SnapConfig(edge: SnapEdge.left),
      );
      final config = fake.lastConfig!;
      expect(config.theme?.badgeColor, equals(0xFFFF0000));
      expect(config.panelAnchor, equals(PanelAnchor.auto));
      expect(config.autoLaunchOnBackground, isTrue);
      expect(config.persistOnAppClose, isTrue);
      expect(config.debugMode, isTrue);
      expect(config.enableDrag, isFalse);
      expect(config.flag, equals(OverlayFlag.clickThrough));
      expect(config.snap?.edge, equals(SnapEdge.left));
    });

    test('show passes entryPointLibrary through', () async {
      await Floaty.show(
        entryPoint: 'overlayMain',
        entryPointLibrary: 'package:app/overlay.dart',
      );
      expect(
        fake.lastConfig?.entryPointLibrary,
        equals('package:app/overlay.dart'),
      );
    });

    test('toggle shows when inactive', () async {
      final result = await Floaty.toggle();
      expect(result, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
    });

    test('toggle closes when active', () async {
      await Floaty.show();
      fake.reset();

      final result = await Floaty.toggle();
      expect(result, isFalse);
      expect(fake.closeChatHeadCalled, isTrue);
    });
  });
}
