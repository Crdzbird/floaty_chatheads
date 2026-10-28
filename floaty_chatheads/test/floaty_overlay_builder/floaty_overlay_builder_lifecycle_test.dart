import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyOverlay.dispose);

  group('FloatyOverlayBuilder', () {
    testWidgets('renders with initialState', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 99,
            onData: (s, d) => s,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('calls onInit after setUp', (tester) async {
      var initCalled = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => s,
            onInit: () => initCalled = true,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      expect(initCalled, isTrue);
    });

    testWidgets('cleans up on unmount', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => s + 1,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );

      await deliverMessengerMessageNow('after');
      await tester.pump();
    });
  });
}
