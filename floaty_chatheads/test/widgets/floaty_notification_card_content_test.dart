import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloatyNotificationCard', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyNotificationCard(
            title: 'Alert',
            body: 'Something happened',
          ),
        ),
      );
      expect(find.text('Alert'), findsOneWidget);
      expect(find.text('Something happened'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyNotificationCard(title: 'Alert', icon: Icons.warning),
        ),
      );
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('renders custom icon widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyNotificationCard(
            title: 'Alert',
            iconWidget: Icon(Icons.star),
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders with custom colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyNotificationCard(
            title: 'Alert',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            accentColor: Colors.amber,
          ),
        ),
      );
      expect(find.text('Alert'), findsOneWidget);
    });
  });
}
