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
