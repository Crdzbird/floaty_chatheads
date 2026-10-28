import 'dart:typed_data';

import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Registers the shared setup used by every AnimatedWidgetIcon test file.
///
/// The Flutter test harness cannot extract bytes from rasterised images,
/// so a synthetic RGBA encoder is installed for each test.
void animatedIconTestSetup() {
  setUp(() {
    testImageEncoder = (image, format) async =>
        ByteData(image.width * image.height * 4);
  });

  tearDown(() => testImageEncoder = null);

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });
}
