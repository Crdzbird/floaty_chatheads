import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyController', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('notifies listeners on show', () async {
      final controller = FloatyController();
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.show();
      expect(notified, isTrue);

      controller.dispose();
    });

    test('notifies listeners on close', () async {
      final controller = FloatyController();
      await controller.show();

      var notified = false;
      controller.addListener(() => notified = true);

      await controller.close();
      expect(notified, isTrue);

      controller.dispose();
    });

    test('passes all config options', () async {
      const theme = ChatHeadTheme(badgeColor: 0xFFFF0000);
      final controller = FloatyController(
        entryPoint: 'custom',
        assets: const ChatHeadAssets(
          icon: IconSource.asset('assets/icon.png'),
          closeIcon: IconSource.asset('assets/close.png'),
          closeBackground: IconSource.asset('assets/closeBg.png'),
        ),
        sizePreset: ContentSizePreset.card,
        theme: theme,
        debugMode: true,
        snap: const SnapConfig(
          edge: SnapEdge.left,
          margin: 5,
          persistPosition: true,
        ),
        entranceAnimation: EntranceAnimation.pop,
      );

      await controller.show();
      final config = fake.lastConfig!;
      expect(config.entryPoint, equals('custom'));
      expect(
        (config.assets!.icon as AssetIconSource).path,
        equals('assets/icon.png'),
      );
      expect(config.sizePreset, equals(ContentSizePreset.card));
      expect(config.theme?.badgeColor, equals(0xFFFF0000));
      expect(config.debugMode, isTrue);
      expect(config.snap?.edge, equals(SnapEdge.left));
      expect(config.snap?.margin, equals(5));
      expect(config.snap?.persistPosition, isTrue);
      expect(config.entranceAnimation, equals(EntranceAnimation.pop));

      controller.dispose();
    });
  });
}
