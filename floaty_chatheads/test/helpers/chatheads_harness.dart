import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_floaty_chatheads_platform.dart';

/// Installs a synthetic RGBA image encoder for every test, because the
/// Flutter test harness cannot extract bytes from rasterised images.
void useSyntheticImageEncoder() {
  setUp(() {
    testImageEncoder = (image, format) async =>
        ByteData(image.width * image.height * 4);
  });

  tearDown(() => testImageEncoder = null);
}

/// Creates a mock platform with native icon support and installs it.
MockFloatyChatheadsPlatform installMockChatheadsPlatform() {
  final platform = MockFloatyChatheadsPlatform();
  when(() => platform.supportsNativeIcons).thenReturn(true);
  FloatyChatheadsPlatform.instance = platform;
  return platform;
}

/// Registers the mocktail fallback values the chathead tests need.
void registerChatheadsFallbacks() {
  registerFallbackValue(const ChatHeadConfig());
  registerFallbackValue(const AddChatHeadConfig(id: ''));
  registerFallbackValue(Uint8List(0));
}
