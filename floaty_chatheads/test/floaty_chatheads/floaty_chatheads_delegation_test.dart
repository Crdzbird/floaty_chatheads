import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/chatheads_harness.dart';
import '../helpers/mock_floaty_chatheads_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  useSyntheticImageEncoder();

  group('FloatyChatheads', () {
    late MockFloatyChatheadsPlatform platform;

    setUp(() => platform = installMockChatheadsPlatform());

    setUpAll(registerChatheadsFallbacks);

    tearDown(FloatyChatheads.dispose);

    test('checkPermission delegates to platform', () async {
      when(() => platform.checkPermission()).thenAnswer((_) async => true);
      expect(await FloatyChatheads.checkPermission(), isTrue);
      verify(() => platform.checkPermission()).called(1);
    });

    test('requestPermission delegates to platform', () async {
      when(() => platform.requestPermission()).thenAnswer((_) async => true);
      expect(await FloatyChatheads.requestPermission(), isTrue);
    });

    test('showChatHead delegates to platform', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead();
      verify(() => platform.showChatHead(any())).called(1);
    });

    test('showChatHead passes config correctly', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead(
        entryPoint: 'myOverlay',
        contentWidth: 300,
        contentHeight: 400,
        debugMode: true,
        sizePreset: ContentSizePreset.card,
        snap: const SnapConfig(edge: SnapEdge.left),
      );
      final captured = verify(
        () => platform.showChatHead(captureAny()),
      ).captured;
      final config = captured.first as ChatHeadConfig;
      expect(config.entryPoint, equals('myOverlay'));
      expect(config.contentWidth, equals(300));
      expect(config.contentHeight, equals(400));
      expect(config.debugMode, isTrue);
      expect(config.sizePreset, equals(ContentSizePreset.card));
      expect(config.snap?.edge, equals(SnapEdge.left));
    });

    test('showChatHead defaults panelAnchor to below', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead();
      final captured = verify(
        () => platform.showChatHead(captureAny()),
      ).captured;
      final config = captured.first as ChatHeadConfig;
      expect(config.panelAnchor, equals(PanelAnchor.below));
    });
  });
}
