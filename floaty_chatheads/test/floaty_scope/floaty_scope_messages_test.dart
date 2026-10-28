import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/services.dart';
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
    testWidgets('updates lastMessage when data arrives', (tester) async {
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

      final encoded = const JSONMessageCodec().encodeMessage('hello');
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'ni.devotion.floaty_head/messenger',
            encoded,
            (data) {},
          );

      await tester.pump();
      expect(data!.lastMessage, equals('hello'));
      expect(data!.messages, contains('hello'));
    });

    testWidgets('updates palette when palette changes', (tester) async {
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

      final paletteMessage = {
        '__floaty__': '_floaty_theme',
        '_floaty_theme': {'primary': 0xFF6200EE},
      };
      final encoded = const JSONMessageCodec().encodeMessage(paletteMessage);
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'ni.devotion.floaty_head/messenger',
            encoded,
            (data) {},
          );

      await tester.pump();
      expect(data!.palette, isNotNull);
    });
  });
}
