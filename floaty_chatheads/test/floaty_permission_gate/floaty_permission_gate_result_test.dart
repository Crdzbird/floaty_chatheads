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
  });
}
