import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OverlayColorPalette', () {
    test('exposes all standard color keys', FloatyOverlay.setUp);

    test('palette getters return correct colors from setUp', () async {
      FloatyOverlay.dispose();
      FloatyOverlay.setUp();

      final completer = Completer<OverlayColorPalette>();
      FloatyOverlay.onPaletteChanged.listen(completer.complete);

      final paletteMessage = {
        '__floaty__': '_floaty_theme',
        '_floaty_theme': {
          'primary': 0xFF6200EE,
          'secondary': 0xFF03DAC6,
          'surface': 0xFFFFFFFF,
          'background': 0xFFF5F0FF,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFF000000,
          'onSurface': 0xDD000000,
          'error': 0xFFB00020,
          'onError': 0xFFFFFFFF,
        },
      };

      final encoded = const JSONMessageCodec().encodeMessage(paletteMessage);
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'ni.devotion.floaty_head/messenger',
            encoded,
            (data) {},
          );

      await Future<void>.delayed(Duration.zero);

      final palette = await completer.future;
      expect(palette.primary, isNotNull);
      expect(palette.secondary, isNotNull);
      expect(palette.surface, isNotNull);
      expect(palette.background, isNotNull);
      expect(palette.onPrimary, isNotNull);
      expect(palette.onSecondary, isNotNull);
      expect(palette.onSurface, isNotNull);
      expect(palette.error, isNotNull);
      expect(palette.onError, isNotNull);
      expect(palette['primary'], isNotNull);
      expect(palette['nonexistent'], isNull);
      expect(palette.toString(), contains('OverlayColorPalette'));
    });
  });
}
