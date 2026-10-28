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
      await Floaty.show(entryPointLibrary: 'package:app/overlay.dart');
      expect(
        fake.lastConfig?.entryPointLibrary,
        equals('package:app/overlay.dart'),
      );
    });
  });
}
