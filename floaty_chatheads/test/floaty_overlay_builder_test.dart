import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/generated/floaty_chatheads_overlay_api.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _simulateMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'ni.devotion.floaty_head/messenger',
    encoded,
    (data) {},
  );
}

Future<void> _simulateTap(String id) async {
  final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
      .encodeMessage(<Object?>[id]);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'dev.flutter.pigeon.floaty_chatheads.'
        'FloatyOverlayFlutterApi.onChatHeadTapped',
    encoded,
    (data) {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyOverlay.dispose);

  group('FloatyOverlayBuilder', () {
    testWidgets('renders with initialState', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 99,
            onData: (s, d) => s,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('calls onData reducer and rebuilds', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) =>
                d is Map && d['v'] is int ? d['v'] as int : s,
            builder: (context, state) => Text('val:$state'),
          ),
        ),
      );

      expect(find.text('val:0'), findsOneWidget);

      await _simulateMessage({'v': 7});
      await tester.pump();
      expect(find.text('val:7'), findsOneWidget);
    });

    testWidgets('calls onTapped when chathead is tapped', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => s,
            onTapped: (s, id) => s + 1,
            builder: (context, state) => Text('taps:$state'),
          ),
        ),
      );

      expect(find.text('taps:0'), findsOneWidget);

      await _simulateTap('default');
      await tester.pump();
      expect(find.text('taps:1'), findsOneWidget);
    });

    testWidgets('calls onInit after setUp', (tester) async {
      var initCalled = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => s,
            onInit: () => initCalled = true,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      expect(initCalled, isTrue);
    });

    testWidgets('cleans up on unmount', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayBuilder<int>(
            initialState: 0,
            onData: (s, d) => s + 1,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );

      // Message after unmount should not crash.
      await _simulateMessage('after');
      await tester.pump();
    });
  });
}
