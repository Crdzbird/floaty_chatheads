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
      test('isIconAnimating is false by default', () {
        expect(FloatyChatheads.isIconAnimating, isFalse);
      });

      test('stopIconAnimation is safe without animation', () {
        FloatyChatheads.stopIconAnimation();
        expect(FloatyChatheads.isIconAnimating, isFalse);
      });

      test('startIconAnimation is safe without animation', () {
        FloatyChatheads.startIconAnimation();
        expect(FloatyChatheads.isIconAnimating, isFalse);
      });

      testWidgets(
        'showChatHead with iconBuilder creates and starts animation',
        (tester) async {
          when(() => platform.showChatHead(any())).thenAnswer((_) async {});
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

          FloatyChatheads.stopIconAnimation();
          expect(FloatyChatheads.isIconAnimating, isFalse);

          FloatyChatheads.startIconAnimation();
          expect(FloatyChatheads.isIconAnimating, isTrue);

          FloatyChatheads.dispose();
          expect(FloatyChatheads.isIconAnimating, isFalse);
        },
      );

      testWidgets('showChatHead with iconWidget renders static icon', (
        tester,
      ) async {
        when(() => platform.showChatHead(any())).thenAnswer((_) async {});

        await FloatyChatheads.showChatHead(
          iconWidget: const SizedBox(width: 10, height: 10),
          iconSize: 10,
          iconPixelRatio: 1,
        );

        expect(FloatyChatheads.isIconAnimating, isFalse);
        verify(() => platform.showChatHead(any())).called(1);
      });
    });
  });
}
