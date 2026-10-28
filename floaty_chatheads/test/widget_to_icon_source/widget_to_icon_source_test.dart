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
    testImageEncoder = (image, format) async =>
        ByteData(image.width * image.height * 4);
  });

  tearDown(() => testImageEncoder = null);

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
