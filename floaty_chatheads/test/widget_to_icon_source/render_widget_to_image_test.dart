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

  group('renderWidgetToImage', () {
    testWidgets('returns a ui.Image with correct dimensions', (tester) async {
      final image = await renderWidgetToImage(
        testWidget,
        size: testSize,
        pixelRatio: testPixelRatio,
      );
      expect(image.width, equals(10));
      expect(image.height, equals(10));
      image.dispose();
    });

    testWidgets('respects pixelRatio', (tester) async {
      final image = await renderWidgetToImage(
        testWidget,
        size: testSize,
        pixelRatio: 2,
      );
      expect(image.width, equals(20));
      expect(image.height, equals(20));
      image.dispose();
    });

    testWidgets('cleans up FocusManager across multiple renders', (
      tester,
    ) async {
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
}
