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

    group('icon animation state', () {
      testWidgets('showChatHead falls back to assets for close icon', (
        tester,
      ) async {
        when(() => platform.showChatHead(any())).thenAnswer((_) async {});

        const customAssets = ChatHeadAssets(
          icon: IconSource.asset('a_icon.png'),
          closeIcon: IconSource.asset('a_close.png'),
          closeBackground: IconSource.asset('a_bg.png'),
        );

        await FloatyChatheads.showChatHead(
          closeBackgroundWidget: const SizedBox(width: 10, height: 10),
          assets: customAssets,
          iconSize: 10,
          iconPixelRatio: 1,
        );

        final captured = verify(
          () => platform.showChatHead(captureAny()),
        ).captured;
        final config = captured.first as ChatHeadConfig;
        expect(config.assets!.closeIcon, const IconSource.asset('a_close.png'));
      });

      testWidgets('closeChatHead disposes animation', (tester) async {
        when(() => platform.showChatHead(any())).thenAnswer((_) async {});
        when(() => platform.closeChatHead()).thenAnswer((_) async {});
        when(
          () => platform.updateChatHeadIcon(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        await FloatyChatheads.showChatHead(
          iconBuilder: (_) => const SizedBox(width: 10, height: 10),
          animateIcon: true,
          iconSize: 10,
          iconPixelRatio: 1,
        );
        expect(FloatyChatheads.isIconAnimating, isTrue);

        await FloatyChatheads.closeChatHead();
        expect(FloatyChatheads.isIconAnimating, isFalse);

        FloatyChatheads.startIconAnimation();
        expect(FloatyChatheads.isIconAnimating, isFalse);
      });
    });
  });
}
