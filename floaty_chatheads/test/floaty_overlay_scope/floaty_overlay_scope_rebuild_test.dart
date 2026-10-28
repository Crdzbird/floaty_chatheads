import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scope_overlay_setup.dart';
import '../helpers/scope_test_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetOverlayScope);

  group('FloatyOverlayScope', () {
    testWidgets('rebuilds on state changes', (tester) async {
      ScopeTestState? state;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<ScopeTestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: ScopeTestState.fromJson,
            initialState: ScopeTestState(),
            builder: (context, k, s, c) {
              state = s;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(state!.counter, equals(0));

      await scopeDeliverMessage({
        '__floaty__': '_floaty_state',
        '_floaty_state': {
          'full': true,
          'data': {'counter': 42, 'label': 'updated'},
        },
      });
      await tester.pump();

      expect(state!.counter, equals(42));
      expect(state!.label, equals('updated'));
    });

    testWidgets('rebuilds on connection changes', (tester) async {
      bool? connected;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<ScopeTestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: ScopeTestState.fromJson,
            initialState: ScopeTestState(),
            builder: (context, k, s, c) {
              connected = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await scopeDeliverMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });
      await tester.pump();

      expect(connected, isFalse);

      await scopeDeliverMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });
      await tester.pump();

      expect(connected, isTrue);
    });
  });
}
