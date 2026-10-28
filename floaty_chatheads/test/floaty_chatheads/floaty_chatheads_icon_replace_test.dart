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
      testWidgets('showChatHead replaces previous animation', (tester) async {
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

        await FloatyChatheads.showChatHead(
          iconWidget: const SizedBox(width: 10, height: 10),
          iconSize: 10,
          iconPixelRatio: 1,
        );
        expect(FloatyChatheads.isIconAnimating, isFalse);
      });
    });
  });
}
