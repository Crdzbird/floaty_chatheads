import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
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

    test('showChatHead skips icon rendering without native icons', () async {
      when(() => platform.supportsNativeIcons).thenReturn(false);
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead(
        iconBuilder: (_) => const SizedBox(width: 4, height: 4),
        animateIcon: true,
      );
      final captured = verify(
        () => platform.showChatHead(captureAny()),
      ).captured;
      expect((captured.first as ChatHeadConfig).assets, isNull);
      expect(FloatyChatheads.isIconAnimating, isFalse);
    });

    test('addChatHead skips widget rendering without native icons', () async {
      when(() => platform.supportsNativeIcons).thenReturn(false);
      when(() => platform.addChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.addChatHead(
        id: 'b',
        iconWidget: const SizedBox(width: 4, height: 4),
      );
      final captured = verify(
        () => platform.addChatHead(captureAny()),
      ).captured;
      expect((captured.first as AddChatHeadConfig).iconSource, isNull);
    });

    test('showChatHead passes readyTimeout through', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead(readyTimeout: Duration.zero);
      final captured = verify(
        () => platform.showChatHead(captureAny()),
      ).captured;
      expect((captured.first as ChatHeadConfig).readyTimeout, Duration.zero);
    });

    test('showChatHead passes panelAnchor through', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead(panelAnchor: PanelAnchor.auto);
      final captured = verify(
        () => platform.showChatHead(captureAny()),
      ).captured;
      final config = captured.first as ChatHeadConfig;
      expect(config.panelAnchor, equals(PanelAnchor.auto));
    });
  });
}
