import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/animated_icon_mock_platform.dart';
import '../helpers/animated_icon_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  animatedIconTestSetup();

  group('AnimatedWidgetIcon', () {
    group('initialFrame', () {
      test('asserts before init()', () {
        final icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox.shrink(),
        );
        expect(() => icon.initialFrame, throwsA(isA<AssertionError>()));
        icon.dispose();
      });

      testWidgets('is available after init()', (tester) async {
        final icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox(width: 10, height: 10),
          size: 10,
          pixelRatio: 1,
        );
        await icon.init();
        expect(icon.initialFrame, isA<IconSource>());
        icon.dispose();
      });
    });

    testWidgets('tick() renders a frame and sends to platform', (tester) async {
      final platform = AnimatedIconMockPlatform();
      FloatyChatheadsPlatform.instance = platform;

      when(
        () => platform.updateChatHeadIcon(any(), any(), any(), any()),
      ).thenAnswer((_) async {});

      final icon =
          AnimatedWidgetIcon(
              id: 'bubble',
              builder: (_) => const SizedBox(width: 10, height: 10),
              fps: 30,
              size: 10,
              pixelRatio: 1,
            )
            ..start()
            ..stop();

      await icon.tick();

      icon.dispose();

      verify(
        () => platform.updateChatHeadIcon('bubble', any(), any(), any()),
      ).called(1);
    });
  });
}
