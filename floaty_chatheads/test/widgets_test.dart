import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloatyMiniPlayer', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(
            title: 'Test Track',
            subtitle: 'Test Artist',
          ),
        ),
      );
      expect(find.text('Test Track'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('shows play icon when not playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(title: 'Track'),
        ),
      );
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });

    testWidgets('shows pause icon when playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(title: 'Track', isPlaying: true),
        ),
      );
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('calls onPlayPause when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyMiniPlayer(
            title: 'Track',
            onPlayPause: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('calls onNext when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyMiniPlayer(
            title: 'Track',
            onNext: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('calls onPrevious when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyMiniPlayer(
            title: 'Track',
            onPrevious: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.skip_previous_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('shows close button when onClose provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FloatyMiniPlayer(
            title: 'Track',
            onClose: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button when onClose is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FloatyMiniPlayer(title: 'Track'),
        ),
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
          home: FloatyMiniPlayer(
            title: 'Track',
            albumArt: Icon(Icons.album),
          ),
        ),
      );
      expect(find.byIcon(Icons.album), findsOneWidget);
    });
  });

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
          home: FloatyNotificationCard(
            title: 'Alert',
            icon: Icons.warning,
          ),
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
          home: FloatyNotificationCard(
            title: 'Alert',
            onDismiss: () {},
          ),
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
              FloatyNotificationAction(
                label: 'Cancel',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(actionPressed, isTrue);
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

  group('ChatHeadDragEvent', () {
    test('toString includes all fields', () {
      const event = ChatHeadDragEvent(id: 'default', x: 10, y: 20);
      expect(
        event.toString(),
        equals('ChatHeadDragEvent(id: default, x: 10.0, y: 20.0)'),
      );
    });

    test('fields are accessible', () {
      const event = ChatHeadDragEvent(id: 'bubble1', x: 5.5, y: 7.3);
      expect(event.id, equals('bubble1'));
      expect(event.x, equals(5.5));
      expect(event.y, equals(7.3));
    });
  });
}
