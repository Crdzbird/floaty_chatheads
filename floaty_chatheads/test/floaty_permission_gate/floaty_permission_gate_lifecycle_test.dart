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
    testWidgets('re-checks on app lifecycle resume', (tester) async {
      fake.permissionGranted = false;

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Denied'), findsOneWidget);

      fake.permissionGranted = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsOneWidget);
    });

    testWidgets('disposes cleanly', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );
    });

    testWidgets('does not re-check on resume when already granted', (
      tester,
    ) async {
      fake.permissionGranted = true;

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      fake.checkPermissionCalled = false;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(fake.checkPermissionCalled, isFalse);
    });
  });
}
