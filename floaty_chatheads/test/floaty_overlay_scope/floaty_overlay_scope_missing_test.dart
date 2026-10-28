import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scope_overlay_setup.dart';
import '../helpers/scope_test_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetOverlayScope);

  group('FloatyOverlayScope', () {
    testWidgets('maybeOf() returns null when no ancestor', (tester) async {
      FloatyOverlayKit<ScopeTestState>? result;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              result = FloatyOverlayScope.maybeOf<ScopeTestState>(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, isNull);
    });

    testWidgets('of() throws when no ancestor', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(
                () => FloatyOverlayScope.of<ScopeTestState>(context),
                throwsAssertionError,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
