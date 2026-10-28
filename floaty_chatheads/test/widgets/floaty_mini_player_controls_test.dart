import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloatyMiniPlayer', () {
    testWidgets('shows play icon when not playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FloatyMiniPlayer(title: 'Track')),
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
          home: FloatyMiniPlayer(title: 'Track', onNext: () => tapped = true),
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
  });
}
