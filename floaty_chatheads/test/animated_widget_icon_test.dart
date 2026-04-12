import 'dart:async';
import 'dart:typed_data';

import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FloatyChatheadsPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The Flutter test harness cannot extract bytes from rasterised
    // images (toByteData hangs). Provide synthetic RGBA data instead.
    testImageEncoder = (image, format) async =>
        ByteData(image.width * image.height * 4);
  });

  tearDown(() => testImageEncoder = null);

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

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
        icon.start();
        icon.stop();
        expect(icon.isRunning, isFalse);
      });

      test('start after stop resumes', () {
        icon.start();
        icon.stop();
        icon.start();
        expect(icon.isRunning, isTrue);
      });

      test('double start is no-op', () {
        icon.start();
        icon.start(); // should not throw
        expect(icon.isRunning, isTrue);
      });
    });

    group('dispose', () {
      test('stops the timer and sets isRunning to false', () {
        final icon = AnimatedWidgetIcon(
          id: 'test',
          builder: (_) => const SizedBox.shrink(),
          fps: 1,
        );
        icon.start();
        expect(icon.isRunning, isTrue);
        icon.dispose();
        expect(icon.isRunning, isFalse);
      });
    });

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
          pixelRatio: 1.0,
        );
        await icon.init();
        expect(icon.initialFrame, isA<IconSource>());
        icon.dispose();
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

    testWidgets('tick() renders a frame and sends to platform',
        (tester) async {
      final platform = MockPlatform();
      FloatyChatheadsPlatform.instance = platform;

      when(
        () => platform.updateChatHeadIcon(any(), any(), any(), any()),
      ).thenAnswer((_) async {});

      final icon = AnimatedWidgetIcon(
        id: 'bubble',
        builder: (_) => const SizedBox(width: 10, height: 10),
        fps: 30,
        size: 10,
        pixelRatio: 1.0,
        duration: const Duration(seconds: 1),
      );

      // Start stopwatch so elapsed > 0 for the animation value.
      icon.start();
      icon.stop();

      // Directly invoke tick() — avoids Timer + toImage deadlock
      // in the faked async test zone.
      await icon.tick();

      icon.dispose();

      verify(
        () => platform.updateChatHeadIcon('bubble', any(), any(), any()),
      ).called(1);
    });

    testWidgets('tick() skips when already rendering', (tester) async {
      final platform = MockPlatform();
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
        pixelRatio: 1.0,
        duration: const Duration(seconds: 1),
      );

      // First tick starts rendering (stalls on completer).
      final firstTick = icon.tick();

      // Second tick should be skipped (_rendering == true).
      await icon.tick();

      // Release the stalled tick.
      completer.complete();
      await firstTick;

      icon.dispose();

      // Only 1 platform call — the second tick was skipped.
      expect(callCount, equals(1));
    });
  });
}
