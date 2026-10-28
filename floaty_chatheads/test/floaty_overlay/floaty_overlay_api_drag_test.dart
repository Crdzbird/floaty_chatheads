import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/generated/'
    'floaty_chatheads_overlay_api.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyOverlay', () {
    setUp(FloatyOverlay.dispose);

    test('API implementation onChatHeadCollapsed emits to stream', () async {
      final ids = <String>[];
      FloatyOverlay.onCollapsed.listen(ids.add);
      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>['default'],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>['default', 10.0, 20.0],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>['default', 100.0, 200.0],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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
}
