import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFloatyPlatform fake;

  setUp(() {
    fake = FakeFloatyPlatform();
    FloatyChatheadsPlatform.instance = fake;
  });

  group('FloatyPermissionGate', () {
    testWidgets('shows SizedBox.shrink while loading', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      expect(find.text('Granted'), findsNothing);
      expect(find.text('Denied'), findsNothing);

      await tester.pumpAndSettle();
    });

    testWidgets('switches from fallback to child when permission granted', (
      tester,
    ) async {
      fake.permissionGranted = false;

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            checkInterval: Duration(milliseconds: 100),
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Denied'), findsOneWidget);

      fake.permissionGranted = true;

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsOneWidget);
    });

    testWidgets('poll timer stops when permission granted', (tester) async {
      fake.permissionGranted = false;

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            checkInterval: Duration(milliseconds: 50),
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      fake.permissionGranted = true;
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsOneWidget);

      fake.checkPermissionCalled = false;
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}
