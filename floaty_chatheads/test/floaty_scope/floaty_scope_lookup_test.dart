import 'package:floaty_chatheads/floaty_chatheads.dart';
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
    testWidgets('provides data to descendants', (tester) async {
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

      expect(data, isNotNull);
      expect(data!.lastMessage, isNull);
      expect(data!.messages, isEmpty);
      expect(data!.lastTappedId, isNull);
      expect(data!.lastClosedId, isNull);
      expect(data!.lastExpandedId, isNull);
      expect(data!.lastCollapsedId, isNull);
      expect(data!.lastDragStart, isNull);
      expect(data!.lastDragEnd, isNull);
      expect(data!.palette, isNull);
    });

    testWidgets('maybeOf returns null when no ancestor', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              data = FloatyScope.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(data, isNull);
    });

    testWidgets('of throws when no ancestor', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(() => FloatyScope.of(context), throwsAssertionError);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
