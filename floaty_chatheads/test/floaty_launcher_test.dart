import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyLauncher', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('show checks permission and shows chathead', () async {
      final result = await FloatyLauncher.show(
        entryPoint: 'testOverlay',
        chatheadIcon: 'assets/icon.png',
      );
      expect(result, isTrue);
      expect(fake.checkPermissionCalled, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('testOverlay'));
      expect(
        fake.lastConfig?.chatheadIconAsset,
        equals('assets/icon.png'),
      );
    });

    test('show requests permission when not granted', () async {
      fake.permissionGranted = false;
      final result = await FloatyLauncher.show();
      expect(result, isFalse);
      expect(fake.checkPermissionCalled, isTrue);
      expect(fake.requestPermissionCalled, isTrue);
      expect(fake.showChatHeadCalled, isFalse);
    });

    test('show passes size preset', () async {
      await FloatyLauncher.show(sizePreset: ContentSizePreset.halfScreen);
      expect(
        fake.lastConfig?.sizePreset,
        equals(ContentSizePreset.halfScreen),
      );
    });

    test('show passes theme', () async {
      final theme = ChatHeadTheme(badgeColor: 0xFFFF0000);
      await FloatyLauncher.show(theme: theme);
      expect(fake.lastConfig?.theme?.badgeColor, equals(0xFFFF0000));
    });

    test('show passes debug mode', () async {
      await FloatyLauncher.show(debugMode: true);
      expect(fake.lastConfig?.debugMode, isTrue);
    });

    test('toggle shows when inactive', () async {
      final result = await FloatyLauncher.toggle();
      expect(result, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
    });

    test('toggle closes when active', () async {
      // First show.
      await FloatyLauncher.show();
      fake.reset();

      // Now toggle should close.
      final result = await FloatyLauncher.toggle();
      expect(result, isFalse);
      expect(fake.closeChatHeadCalled, isTrue);
    });
  });
}
