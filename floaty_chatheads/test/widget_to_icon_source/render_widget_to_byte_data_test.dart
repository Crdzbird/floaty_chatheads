import 'dart:typed_data';

import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
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

  group('renderWidgetToPngByteData', () {
    testWidgets('returns non-empty byte data', (tester) async {
      final byteData = await renderWidgetToPngByteData(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(byteData.lengthInBytes, greaterThan(0));
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
}
