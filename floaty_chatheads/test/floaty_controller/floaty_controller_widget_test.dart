import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyControllerWidget', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    testWidgets('shows chathead on mount', (tester) async {
      await tester.pumpWidget(
        const FloatyControllerWidget(
          entryPoint: 'test',
          child: SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();
      expect(fake.showChatHeadCalled, isTrue);
    });

    testWidgets('of returns controller from descendant context', (
      tester,
    ) async {
      FloatyController? foundController;
      await tester.pumpWidget(
        FloatyControllerWidget(
          entryPoint: 'test',
          child: Builder(
            builder: (context) {
              foundController = FloatyControllerWidget.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(foundController, isNotNull);
      expect(foundController!.isActive, isTrue);
    });

    testWidgets('of returns null when no ancestor', (tester) async {
      FloatyController? foundController;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            foundController = FloatyControllerWidget.of(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(foundController, isNull);
    });

    testWidgets('renders builder when provided', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyControllerWidget(
            entryPoint: 'test',
            builder: (context, controller) {
              return Text(controller.isActive ? 'Active' : 'Inactive');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(fake.showChatHeadCalled, isTrue);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('closes chathead on unmount', (tester) async {
      await tester.pumpWidget(
        const FloatyControllerWidget(
          entryPoint: 'test',
          child: SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();
      expect(fake.showChatHeadCalled, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
