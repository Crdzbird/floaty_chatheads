import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/generated/'
    'floaty_chatheads_overlay_api.g.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyConnectionState.dispose();
    FloatyOverlay.dispose();
    FloatyOverlay.setUp();
    FloatyConnectionState.setUp();
  });

  group('FloatyScope', () {
    testWidgets('updates lastDragStart when drag starts', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

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

      await tester.pump();
      expect(data!.lastDragStart, isNotNull);
      expect(data!.lastDragStart!.x, equals(10.0));
    });

    testWidgets('updates lastDragEnd when drag ends', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

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

      await tester.pump();
      expect(data!.lastDragEnd, isNotNull);
      expect(data!.lastDragEnd!.x, equals(100.0));
    });
  });
}
