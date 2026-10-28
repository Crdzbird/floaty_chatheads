import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/generated/'
    'floaty_chatheads_overlay_api.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyOverlay', () {
    setUp(FloatyOverlay.dispose);

    test('API implementation onChatHeadTapped emits to stream', () async {
      final ids = <String>[];
      FloatyOverlay.onTapped.listen(ids.add);

      FloatyOverlay.setUp();

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>['default'],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>['bubble1'],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>['default'],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadExpanded',
            encoded,
            (data) {},
          );

      await Future<void>.delayed(Duration.zero);
      expect(ids, contains('default'));
    });
  });
}
