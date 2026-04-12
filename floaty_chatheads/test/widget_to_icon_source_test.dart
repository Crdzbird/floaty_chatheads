import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testWidget = SizedBox(width: 10, height: 10);
  const testSize = 10.0;
  const testPixelRatio = 1.0;

  setUp(() {
    // The Flutter test harness cannot extract bytes from rasterised
    // images (toByteData hangs). Provide synthetic RGBA data instead.
    testImageEncoder = (image, format) async =>
        ByteData(image.width * image.height * 4);
  });

  tearDown(() => testImageEncoder = null);

  group('renderWidgetToImage', () {
    testWidgets('returns a ui.Image with correct dimensions', (tester) async {
      final image = await renderWidgetToImage(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      // At pixelRatio 1.0 and size 10, image should be 10x10 pixels.
      expect(image.width, equals(10));
      expect(image.height, equals(10));
      image.dispose();
    });

    testWidgets('respects pixelRatio', (tester) async {
      final image = await renderWidgetToImage(
        testWidget,
        size: testSize,
        pixelRatio: 2.0,
      );
      expect(image.width, equals(20));
      expect(image.height, equals(20));
      image.dispose();
    });

    testWidgets('cleans up FocusManager across multiple renders',
        (tester) async {
      // Multiple sequential renders should not leak FocusManagers.
      for (var i = 0; i < 3; i++) {
        final image = await renderWidgetToImage(
          testWidget,
          size: testSize,
          pixelRatio: testPixelRatio,
        );
        image.dispose();
      }
    });
  });

  group('renderWidgetToPngByteData', () {
    testWidgets('returns non-empty byte data', (tester) async {
      final byteData = await renderWidgetToPngByteData(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      // 10x10 at 1.0 pixel ratio → 10*10*4 RGBA bytes.
      expect(byteData.lengthInBytes, equals(10 * 10 * 4));
    });
  });

  group('renderWidgetToRgbaByteData', () {
    testWidgets('returns correct dimensions and byte count', (tester) async {
      final (:bytes, :width, :height) = await renderWidgetToRgbaByteData(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(width, equals(10));
      expect(height, equals(10));
      // RGBA = 4 bytes per pixel.
      expect(bytes.lengthInBytes, equals(10 * 10 * 4));
    });
  });

  group('renderWidgetToBytes', () {
    testWidgets('returns Uint8List of rendered bytes', (tester) async {
      final bytes = await renderWidgetToBytes(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(0));
    });
  });

  group('widgetToIconSource', () {
    testWidgets('returns an IconSource.bytes', (tester) async {
      final source = await widgetToIconSource(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(source, isA<IconSource>());
    });

    testWidgets('uses default pixelRatio of 3.0', (tester) async {
      // Should not throw with the default pixelRatio.
      final source = await widgetToIconSource(testWidget, size: testSize);
      expect(source, isA<IconSource>());
    });
  });

  group('_encodeImage', () {
    testWidgets('delegates to testImageEncoder when set', (tester) async {
      ui.ImageByteFormat? capturedFormat;
      testImageEncoder = (image, format) async {
        capturedFormat = format;
        return ByteData(4);
      };

      await renderWidgetToPngByteData(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(capturedFormat, equals(ui.ImageByteFormat.png));

      await renderWidgetToRgbaByteData(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(capturedFormat, equals(ui.ImageByteFormat.rawRgba));
    });
  });
}
