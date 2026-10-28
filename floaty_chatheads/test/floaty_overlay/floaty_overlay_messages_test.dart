import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyOverlay', () {
    setUp(FloatyOverlay.dispose);

    test('setUp processes data messages via BasicMessageChannel', () async {
      FloatyOverlay.setUp();

      final completer = Completer<Object?>();
      FloatyOverlay.onData.listen(completer.complete);

      final handler =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final encoded = const JSONMessageCodec().encodeMessage('hello');
      await handler.handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);

      expect(completer.isCompleted, isTrue);
      expect(await completer.future, equals('hello'));
    });

    test('setUp intercepts theme palette messages', () async {
      FloatyOverlay.setUp();

      final palettes = <OverlayColorPalette>[];
      final sub = FloatyOverlay.onPaletteChanged.listen(palettes.add);

      final paletteMessage = {
        '__floaty__': '_floaty_theme',
        '_floaty_theme': {'primary': 0xFF6200EE, 'surface': 0xFFFFFFFF},
      };

      final encoded = const JSONMessageCodec().encodeMessage(paletteMessage);
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'ni.devotion.floaty_head/messenger',
            encoded,
            (data) {},
          );

      await Future<void>.delayed(Duration.zero);

      expect(palettes, isNotEmpty);
      final palette = palettes.last;
      expect(FloatyOverlay.palette, isNotNull);
      expect(palette.primary, isNotNull);
      expect(palette.surface, isNotNull);
      await sub.cancel();
    });
  });
}
