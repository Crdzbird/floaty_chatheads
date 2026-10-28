import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scope_overlay_setup.dart';
import '../helpers/scope_test_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetOverlayScope);

  group('FloatyOverlayScope', () {
    testWidgets('of() returns the kit from nearest ancestor', (tester) async {
      FloatyOverlayKit<ScopeTestState>? foundKit;
      FloatyOverlayKit<ScopeTestState>? directKit;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<ScopeTestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: ScopeTestState.fromJson,
            initialState: ScopeTestState(),
            builder: (context, k, s, c) {
              directKit = k;
              return Builder(
                builder: (innerContext) {
                  foundKit = FloatyOverlayScope.of<ScopeTestState>(
                    innerContext,
                  );
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      );

      expect(foundKit, isNotNull);
      expect(foundKit, same(directKit));
    });

    testWidgets('maybeOf() returns kit when ancestor exists', (tester) async {
      FloatyOverlayKit<ScopeTestState>? result;
      FloatyOverlayKit<ScopeTestState>? directKit;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<ScopeTestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: ScopeTestState.fromJson,
            initialState: ScopeTestState(),
            builder: (context, k, s, c) {
              directKit = k;
              return Builder(
                builder: (innerContext) {
                  result = FloatyOverlayScope.maybeOf<ScopeTestState>(
                    innerContext,
                  );
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      );

      expect(result, isNotNull);
      expect(result, same(directKit));
    });
  });
}
