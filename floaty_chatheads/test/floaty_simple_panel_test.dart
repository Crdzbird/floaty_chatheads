import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloatySimplePanel', () {
    Future<void> pumpPanel(WidgetTester tester, Widget panel) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: panel)));
    }

    testWidgets('renders child', (tester) async {
      await pumpPanel(
        tester,
        const FloatySimplePanel(child: Text('payload')),
      );
      expect(find.text('payload'), findsOneWidget);
    });

    testWidgets('renders title in header when provided', (tester) async {
      await pumpPanel(
        tester,
        const FloatySimplePanel(
          title: 'Notifications',
          child: Text('hi'),
        ),
      );
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows close icon by default', (tester) async {
      await pumpPanel(
        tester,
        const FloatySimplePanel(child: Text('hi')),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close icon when showCloseButton is false',
        (tester) async {
      await pumpPanel(
        tester,
        const FloatySimplePanel(
          showCloseButton: false,
          child: Text('hi'),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders title without close icon when both flags allow',
        (tester) async {
      await pumpPanel(
        tester,
        const FloatySimplePanel(
          title: 'Only title',
          showCloseButton: false,
          child: Text('hi'),
        ),
      );
      expect(find.text('Only title'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('invokes onClose override when close button tapped',
        (tester) async {
      var tapped = false;
      await pumpPanel(
        tester,
        FloatySimplePanel(
          onClose: () => tapped = true,
          child: const Text('hi'),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('applies custom padding and elevation', (tester) async {
      await pumpPanel(
        tester,
        const FloatySimplePanel(
          padding: EdgeInsets.all(32),
          elevation: 2,
          child: Text('hi'),
        ),
      );
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(2));
    });
  });
}
