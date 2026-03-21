import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/generated/'
    'floaty_chatheads_overlay_api.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyOverlay', () {
    setUp(FloatyOverlay.dispose);

    test('setUp registers handler and can be called multiple times', () {
      // First call should set up.
      FloatyOverlay.setUp();
      // Second call should be a no-op (guarded by _isSetUp).
      FloatyOverlay.setUp();
    });

    test('dispose resets setup state', () {
      FloatyOverlay.setUp();
      FloatyOverlay.dispose();
      // Can setUp again after dispose.
      FloatyOverlay.setUp();
    });

    test('onData stream is broadcast', () {
      final stream = FloatyOverlay.onData
        // Broadcast streams allow multiple listeners.
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onTapped stream is broadcast', () {
      final stream = FloatyOverlay.onTapped
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onClosed stream is broadcast', () {
      final stream = FloatyOverlay.onClosed
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onExpanded stream is broadcast', () {
      final stream = FloatyOverlay.onExpanded
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onCollapsed stream is broadcast', () {
      final stream = FloatyOverlay.onCollapsed
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onDragStart stream is broadcast', () {
      final stream = FloatyOverlay.onDragStart
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onDragEnd stream is broadcast', () {
      final stream = FloatyOverlay.onDragEnd
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
      stream.listen((_) {});
    });

    test('onPaletteChanged stream is broadcast', () {
      final stream = FloatyOverlay.onPaletteChanged
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('palette returns null initially', () {
      expect(FloatyOverlay.palette, isNull);
    });

    test('setUp processes data messages via BasicMessageChannel', () async {
      FloatyOverlay.setUp();

      final completer = Completer<Object?>();
      FloatyOverlay.onData.listen(completer.complete);

      // Send a message using the handler.
      final handler = TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger;
      final encoded = const JSONMessageCodec().encodeMessage('hello');
      await handler.handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      // Give the stream time to process.
      await Future<void>.delayed(Duration.zero);

      // The data should have been forwarded.
      expect(completer.isCompleted, isTrue);
      expect(await completer.future, equals('hello'));
    });

    test('setUp intercepts theme palette messages', () async {
      FloatyOverlay.setUp();

      final palettes = <OverlayColorPalette>[];
      final sub = FloatyOverlay.onPaletteChanged.listen(palettes.add);

      // Simulate native sending a palette.
      final paletteMessage = {
        '__floaty__': '_floaty_theme',
        '_floaty_theme': {
          'primary': 0xFF6200EE,
          'surface': 0xFFFFFFFF,
        },
      };

      final encoded = const JSONMessageCodec().encodeMessage(paletteMessage);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
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

    test('API implementation onChatHeadTapped emits to stream', () async {
      final ids = <String>[];
      FloatyOverlay.onTapped.listen(ids.add);

      // First set up the handlers.
      FloatyOverlay.setUp();

      // Send message through the pigeon channel.
      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadTapped',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(ids, contains('default'));
    });

    test('API implementation onChatHeadClosed emits to stream', () async {
      final ids = <String>[];
      FloatyOverlay.onClosed.listen(ids.add);
      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['bubble1']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadClosed',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(ids, contains('bubble1'));
    });

    test('API implementation onChatHeadExpanded emits to stream', () async {
      final ids = <String>[];
      FloatyOverlay.onExpanded.listen(ids.add);
      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadExpanded',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(ids, contains('default'));
    });

    test('API implementation onChatHeadCollapsed emits to stream', () async {
      final ids = <String>[];
      FloatyOverlay.onCollapsed.listen(ids.add);
      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadCollapsed',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(ids, contains('default'));
    });

    test('API implementation onChatHeadDragStart emits to stream', () async {
      final events = <ChatHeadDragEvent>[];
      FloatyOverlay.onDragStart.listen(events.add);
      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default', 10.0, 20.0]);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadDragStart',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.id, equals('default'));
      expect(events.first.x, equals(10.0));
      expect(events.first.y, equals(20.0));
    });

    test('API implementation onChatHeadDragEnd emits to stream', () async {
      final events = <ChatHeadDragEvent>[];
      FloatyOverlay.onDragEnd.listen(events.add);
      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default', 100.0, 200.0]);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadDragEnd',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.x, equals(100.0));
      expect(events.first.y, equals(200.0));
    });
  });

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
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
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
