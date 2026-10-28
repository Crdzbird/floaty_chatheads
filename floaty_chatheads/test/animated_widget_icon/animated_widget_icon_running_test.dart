import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/animated_icon_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  animatedIconTestSetup();

  group('AnimatedWidgetIcon', () {
    group('start / stop / isRunning', () {
      late AnimatedWidgetIcon icon;

      setUp(() {
        icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox.shrink(),
          fps: 1,
          duration: const Duration(seconds: 10),
        );
      });

      tearDown(() => icon.dispose());

      test('isRunning is false initially', () {
        expect(icon.isRunning, isFalse);
      });

      test('start sets isRunning to true', () {
        icon.start();
        expect(icon.isRunning, isTrue);
      });

      test('stop sets isRunning to false', () {
        icon
          ..start()
          ..stop();
        expect(icon.isRunning, isFalse);
      });

      test('start after stop resumes', () {
        icon
          ..start()
          ..stop()
          ..start();
        expect(icon.isRunning, isTrue);
      });

      test('double start is no-op', () {
        icon
          ..start()
          ..start();
        expect(icon.isRunning, isTrue);
      });
    });
  });
}
