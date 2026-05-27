import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Floaty facade', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('show checks permission and shows chathead with defaults', () async {
      final result = await Floaty.show();
      expect(result, isTrue);
      expect(fake.checkPermissionCalled, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('overlayMain'));
      expect(fake.lastConfig?.sizePreset, equals(ContentSizePreset.card));
      expect(fake.lastConfig?.notification, isNull);
    });

    test('show forwards entryPoint, size, and title to launcher', () async {
      await Floaty.show(
        entryPoint: 'customOverlay',
        title: 'My Title',
        size: ContentSizePreset.halfScreen,
        entranceAnimation: EntranceAnimation.pop,
      );
      expect(fake.lastConfig?.entryPoint, equals('customOverlay'));
      expect(fake.lastConfig?.sizePreset, equals(ContentSizePreset.halfScreen));
      expect(fake.lastConfig?.notification?.title, equals('My Title'));
      expect(
        fake.lastConfig?.entranceAnimation,
        equals(EntranceAnimation.pop),
      );
    });

    test('show returns false when permission denied', () async {
      fake.permissionGranted = false;
      final result = await Floaty.show();
      expect(result, isFalse);
      expect(fake.requestPermissionCalled, isTrue);
      expect(fake.showChatHeadCalled, isFalse);
    });

    test('close delegates to platform', () async {
      await Floaty.close();
      expect(fake.closeChatHeadCalled, isTrue);
    });

    test('isActive delegates to platform', () async {
      fake.active = true;
      expect(await Floaty.isActive(), isTrue);
    });

    test('toggle closes when active and shows when inactive', () async {
      fake.active = true;
      final closedResult = await Floaty.toggle();
      expect(closedResult, isFalse);
      expect(fake.closeChatHeadCalled, isTrue);

      fake.active = false;
      final shownResult = await Floaty.toggle(title: 'Toggled');
      expect(shownResult, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.notification?.title, equals('Toggled'));
    });
  });
}
