import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test helpers ─────────────────────────────────────────────────────

class _TestState {
  _TestState({this.counter = 0, this.label = 'ready'});

  factory _TestState.fromJson(Map<String, dynamic> json) => _TestState(
        counter: json['counter'] as int? ?? 0,
        label: json['label'] as String? ?? 'ready',
      );

  final int counter;
  final String label;

  Map<String, dynamic> toJson() => {'counter': counter, 'label': label};
}

Future<void> _simulateMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'ni.devotion.floaty_head/messenger',
    encoded,
    (data) {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Tear down everything first.
    FloatyConnectionState.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.dispose();
    // Then re-initialise in the correct order.
    FloatyChannel.ensureListening();
    FloatyOverlay.setUp(); // registers handlers on the fresh channel
  });

  group('FloatyOverlayScope', () {
    testWidgets('provides kit, state, and connected to builder',
        (tester) async {
      FloatyOverlayKit<_TestState>? kit;
      _TestState? state;
      bool? connected;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<_TestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: _TestState.fromJson,
            initialState: _TestState(),
            builder: (context, k, s, c) {
              kit = k;
              state = s;
              connected = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(kit, isNotNull);
      expect(state, isNotNull);
      expect(state!.counter, equals(0));
      expect(state!.label, equals('ready'));
      expect(connected, isNotNull);
    });

    testWidgets('rebuilds on state changes', (tester) async {
      _TestState? state;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<_TestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: _TestState.fromJson,
            initialState: _TestState(),
            builder: (context, k, s, c) {
              state = s;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(state!.counter, equals(0));

      // Simulate a state update from the host.
      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'counter': 42, 'label': 'updated'},
        },
      });
      await tester.pump();

      expect(state!.counter, equals(42));
      expect(state!.label, equals('updated'));
    });

    testWidgets('of() returns the kit from nearest ancestor',
        (tester) async {
      FloatyOverlayKit<_TestState>? foundKit;
      FloatyOverlayKit<_TestState>? directKit;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<_TestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: _TestState.fromJson,
            initialState: _TestState(),
            builder: (context, k, s, c) {
              directKit = k;
              return Builder(
                builder: (innerContext) {
                  foundKit =
                      FloatyOverlayScope.of<_TestState>(innerContext);
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      );

      expect(foundKit, isNotNull);
      expect(foundKit, same(directKit));
    });

    testWidgets('maybeOf() returns kit when ancestor exists',
        (tester) async {
      FloatyOverlayKit<_TestState>? result;
      FloatyOverlayKit<_TestState>? directKit;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<_TestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: _TestState.fromJson,
            initialState: _TestState(),
            builder: (context, k, s, c) {
              directKit = k;
              return Builder(
                builder: (innerContext) {
                  result =
                      FloatyOverlayScope.maybeOf<_TestState>(innerContext);
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      );

      expect(result, isNotNull);
      expect(result, same(directKit));
    });

    testWidgets('maybeOf() returns null when no ancestor', (tester) async {
      FloatyOverlayKit<_TestState>? result;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              result = FloatyOverlayScope.maybeOf<_TestState>(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, isNull);
    });

    testWidgets('of() throws when no ancestor', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(
                () => FloatyOverlayScope.of<_TestState>(context),
                throwsAssertionError,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('rebuilds on connection changes', (tester) async {
      bool? connected;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<_TestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: _TestState.fromJson,
            initialState: _TestState(),
            builder: (context, k, s, c) {
              connected = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Simulate a disconnection message.
      await _simulateMessage({
        '_floaty_connection': {'connected': false},
      });
      await tester.pump();

      expect(connected, isFalse);

      // Simulate a reconnection message.
      await _simulateMessage({
        '_floaty_connection': {'connected': true},
      });
      await tester.pump();

      expect(connected, isTrue);
    });

    testWidgets('disposes kit and subscriptions on unmount',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyOverlayScope<_TestState>(
            stateToJson: (s) => s.toJson(),
            stateFromJson: _TestState.fromJson,
            initialState: _TestState(),
            builder: (context, k, s, c) => const SizedBox.shrink(),
          ),
        ),
      );

      // Unmount — should not throw.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );
    });
  });
}
