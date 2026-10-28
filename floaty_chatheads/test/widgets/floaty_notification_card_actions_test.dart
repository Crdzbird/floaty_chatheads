import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloatyNotificationCard', () {
    testWidgets('calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyNotificationCard(
            title: 'Alert',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Alert'));
      expect(tapped, isTrue);
    });

    testWidgets('shows dismiss button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyNotificationCard(title: 'Alert', onDismiss: () {}),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      var actionPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyNotificationCard(
            title: 'Alert',
            actions: [
              FloatyNotificationAction(
                label: 'OK',
                onPressed: () => actionPressed = true,
              ),
              FloatyNotificationAction(label: 'Cancel', onPressed: () {}),
            ],
          ),
        ),
      );
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(actionPressed, isTrue);
    });
  });
}
