import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloatyMiniPlayer', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(title: 'Test Track', subtitle: 'Test Artist'),
        ),
      );
      expect(find.text('Test Track'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('shows close button when onClose provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyMiniPlayer(title: 'Track', onClose: () {}),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button when onClose is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FloatyMiniPlayer(title: 'Track')),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders with custom colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(
            title: 'Track',
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            accentColor: Colors.yellow,
          ),
        ),
      );
      expect(find.text('Track'), findsOneWidget);
    });

    testWidgets('renders album art when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(title: 'Track', albumArt: Icon(Icons.album)),
        ),
      );
      expect(find.byIcon(Icons.album), findsOneWidget);
    });
  });
}
