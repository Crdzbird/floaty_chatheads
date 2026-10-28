import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';
import '../helpers/overlay_chat_head_tap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyOverlay.dispose);

  group('FloatyOverlayBuilder', () {
    testWidgets('calls onData reducer and rebuilds', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => d is Map && d['v'] is int ? d['v'] as int : s,
            builder: (context, state) => Text('val:$state'),
          ),
        ),
      );

      expect(find.text('val:0'), findsOneWidget);

      await deliverMessengerMessageNow({'v': 7});
      await tester.pump();
      expect(find.text('val:7'), findsOneWidget);
    });

    testWidgets('calls onTapped when chathead is tapped', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => s,
            onTapped: (s, id) => s + 1,
            builder: (context, state) => Text('taps:$state'),
          ),
        ),
      );

      expect(find.text('taps:0'), findsOneWidget);

      await simulateOverlayChatHeadTap('default');
      await tester.pump();
      expect(find.text('taps:1'), findsOneWidget);
    });
  });
}
