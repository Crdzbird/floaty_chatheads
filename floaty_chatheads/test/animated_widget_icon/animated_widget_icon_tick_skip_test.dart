import 'dart:async';

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
    testWidgets('tick() skips when already rendering', (tester) async {
      final platform = AnimatedIconMockPlatform();
      FloatyChatheadsPlatform.instance = platform;

      final completer = Completer<void>();
      var callCount = 0;
      when(
        () => platform.updateChatHeadIcon(any(), any(), any(), any()),
      ).thenAnswer((_) {
        callCount++;
        if (callCount == 1) return completer.future;
        return Future.value();
      });

      final icon = AnimatedWidgetIcon(
        id: 'test',
        builder: (_) => const SizedBox(width: 10, height: 10),
        fps: 30,
        size: 10,
        pixelRatio: 1,
      );

      final firstTick = icon.tick();

      await icon.tick();

      completer.complete();
      await firstTick;

      icon.dispose();

      expect(callCount, equals(1));
    });
  });
}
