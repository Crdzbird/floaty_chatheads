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
    testWidgets('updates lastTappedId when tapped', (tester) async {
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
        <Object?>['default'],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadTapped',
            encoded,
            (data) {},
          );

      await tester.pump();
      expect(data!.lastTappedId, equals('default'));
    });

    testWidgets('updates lastClosedId when closed', (tester) async {
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
        <Object?>['bubble1'],
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadClosed',
            encoded,
            (data) {},
          );

      await tester.pump();
      expect(data!.lastClosedId, equals('bubble1'));
    });
  });
}
