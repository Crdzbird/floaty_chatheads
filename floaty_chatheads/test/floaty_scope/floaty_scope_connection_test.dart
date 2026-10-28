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
    testWidgets('updates isMainAppConnected on connection change', (
      tester,
    ) async {
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

      final encoded = const JSONMessageCodec().encodeMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'ni.devotion.floaty_head/messenger',
            encoded,
            (data) {},
          );
      await tester.pump();
      expect(data!.isMainAppConnected, isFalse);

      final encoded2 = const JSONMessageCodec().encodeMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'ni.devotion.floaty_head/messenger',
            encoded2,
            (data) {},
          );
      await tester.pump();
      expect(data!.isMainAppConnected, isTrue);
    });

    testWidgets('disposes stream subscriptions on unmount', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(child: SizedBox.shrink()),
        ),
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );
    });
  });
}
