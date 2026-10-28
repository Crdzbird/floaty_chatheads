import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/animated_icon_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  animatedIconTestSetup();

  group('AnimatedWidgetIcon', () {
    group('construction', () {
      test('succeeds with valid parameters', () {
        final icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox.shrink(),
        );
        expect(icon.id, 'test');
        expect(icon.fps, 24);
        expect(icon.size, 80);
        expect(icon.pixelRatio, 3.0);
        expect(icon.duration, const Duration(seconds: 1));
        expect(icon.isRunning, isFalse);
        icon.dispose();
      });

      test('asserts fps > 0', () {
        expect(
          () => AnimatedWidgetIcon(
            id: 'test',
            builder: (_) => const SizedBox.shrink(),
            fps: 0,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts duration > Duration.zero', () {
        expect(
          () => AnimatedWidgetIcon(
            id: 'test',
            builder: (_) => const SizedBox.shrink(),
            duration: Duration.zero,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('dispose', () {
      test('stops the timer and sets isRunning to false', () {
        final icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox.shrink(),
          fps: 1,
        )..start();
        expect(icon.isRunning, isTrue);
        icon.dispose();
        expect(icon.isRunning, isFalse);
      });
    });

    group('builder', () {
      test('can be reassigned', () {
        final icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox.shrink(),
        );
        Widget replacement(double v) => const Placeholder();
        icon.builder = replacement;
        expect(icon.builder, equals(replacement));
        icon.dispose();
      });
    });
  });
}
