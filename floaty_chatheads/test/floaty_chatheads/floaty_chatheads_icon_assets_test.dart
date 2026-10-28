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
      testWidgets(
        'showChatHead with closeIconWidget and closeBackgroundWidget',
        (tester) async {
          when(() => platform.showChatHead(any())).thenAnswer((_) async {});

          await FloatyChatheads.showChatHead(
            iconWidget: const SizedBox(width: 10, height: 10),
            closeIconWidget: const SizedBox(width: 10, height: 10),
            closeBackgroundWidget: const SizedBox(width: 10, height: 10),
            iconSize: 10,
            iconPixelRatio: 1,
          );

          final captured = verify(
            () => platform.showChatHead(captureAny()),
          ).captured;
          final config = captured.first as ChatHeadConfig;
          expect(config.assets, isNotNull);
          expect(config.assets!.icon, isNotNull);
          expect(config.assets!.closeIcon, isNotNull);
          expect(config.assets!.closeBackground, isNotNull);
        },
      );

      testWidgets(
        'showChatHead falls back to assets for icon and close background',
        (tester) async {
          when(() => platform.showChatHead(any())).thenAnswer((_) async {});

          const customAssets = ChatHeadAssets(
            icon: IconSource.asset('custom_icon.png'),
            closeIcon: IconSource.asset('custom_close.png'),
            closeBackground: IconSource.asset('custom_bg.png'),
          );

          await FloatyChatheads.showChatHead(
            closeIconWidget: const SizedBox(width: 10, height: 10),
            assets: customAssets,
            iconSize: 10,
            iconPixelRatio: 1,
          );

          final captured = verify(
            () => platform.showChatHead(captureAny()),
          ).captured;
          final config = captured.first as ChatHeadConfig;
          expect(
            config.assets!.icon,
            const IconSource.asset('custom_icon.png'),
          );
          expect(
            config.assets!.closeBackground,
            const IconSource.asset('custom_bg.png'),
          );
        },
      );
    });
  });
}
