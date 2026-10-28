import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scope_overlay_setup.dart';
import '../helpers/scope_test_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetOverlayScope);

  group('FloatyOverlayScope', () {
    testWidgets('provides kit, state, and connected to builder', (
      tester,
    ) async {
      FloatyOverlayKit<ScopeTestState>? kit;
      ScopeTestState? state;
      bool? connected;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<ScopeTestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: ScopeTestState.fromJson,
            initialState: ScopeTestState(),
            builder: (context, k, s, c) {
              kit = k;
              state = s;
              connected = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(kit, isNotNull);
      expect(state, isNotNull);
      expect(state!.counter, equals(0));
      expect(state!.label, equals('ready'));
      expect(connected, isNotNull);
    });

    testWidgets('disposes kit and subscriptions on unmount', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<ScopeTestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: ScopeTestState.fromJson,
            initialState: ScopeTestState(),
            builder: (context, k, s, c) => const SizedBox.shrink(),
          ),
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
