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
    testWidgets('shows child when permission is granted', (tester) async {
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

      // Wait for async checkPermission to complete.
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsOneWidget);
      expect(find.text('Denied'), findsNothing);
    });

    testWidgets('shows fallback when permission is denied', (tester) async {
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
      expect(find.text('Granted'), findsNothing);
    });

    testWidgets('calls onPermissionGranted when granted', (tester) async {
      fake.permissionGranted = true;
      var granted = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            onPermissionGranted: () => granted = true,
            fallback: const Text('Denied'),
            child: const Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(granted, isTrue);
    });

    testWidgets('calls onPermissionDenied when denied', (tester) async {
      fake.permissionGranted = false;
      var denied = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            onPermissionDenied: () => denied = true,
            fallback: const Text('Denied'),
            child: const Text('Granted'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(denied, isTrue);
    });

    testWidgets('shows SizedBox.shrink while loading', (tester) async {
      // Don't pump and settle — check the loading state.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyPermissionGate(
            fallback: Text('Denied'),
            child: Text('Granted'),
          ),
        ),
      );

      // On the first pump, _loading is still true.
      expect(find.text('Granted'), findsNothing);
      expect(find.text('Denied'), findsNothing);

      // After settling, the state resolves.
      await tester.pumpAndSettle();
    });

    testWidgets('switches from fallback to child when permission granted',
        (tester) async {
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

      // Now grant permission — the poll timer should pick it up.
      fake.permissionGranted = true;

      // Advance time to trigger the poll timer.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsOneWidget);
    });

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

      // Grant permission and simulate app resume.
      fake.permissionGranted = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
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

      // Grant permission.
      fake.permissionGranted = true;
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsOneWidget);

      // Timer should have been cancelled — no further checks.
      fake.checkPermissionCalled = false;
      await tester.pump(const Duration(milliseconds: 200));
      // The timer was cancelled, so checkPermission shouldn't be called again.
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

      // Replace with empty widget to trigger dispose.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );
    });

    testWidgets('does not re-check on resume when already granted',
        (tester) async {
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

      // Clear the flag.
      fake.checkPermissionCalled = false;

      // Simulate resume — should not re-check since already granted.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // checkPermission should NOT have been called again
      // since _granted is true.
      expect(fake.checkPermissionCalled, isFalse);
    });
  });
}
