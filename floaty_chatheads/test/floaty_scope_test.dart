import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/generated/'
    'floaty_chatheads_overlay_api.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyConnectionState.dispose();
    FloatyOverlay.dispose();
    FloatyOverlay.setUp();
    FloatyConnectionState.setUp();
  });

  group('FloatyScope', () {
    testWidgets('provides data to descendants', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(data, isNotNull);
      expect(data!.lastMessage, isNull);
      expect(data!.messages, isEmpty);
      expect(data!.lastTappedId, isNull);
      expect(data!.lastClosedId, isNull);
      expect(data!.lastExpandedId, isNull);
      expect(data!.lastCollapsedId, isNull);
      expect(data!.lastDragStart, isNull);
      expect(data!.lastDragEnd, isNull);
      expect(data!.palette, isNull);
    });

    testWidgets('maybeOf returns null when no ancestor', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              data = FloatyScope.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(data, isNull);
    });

    testWidgets('of throws when no ancestor', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(
                () => FloatyScope.of(context),
                throwsAssertionError,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('updates lastMessage when data arrives', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = const JSONMessageCodec().encodeMessage('hello');
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastMessage, equals('hello'));
      expect(data!.messages, contains('hello'));
    });

    testWidgets('updates lastTappedId when tapped', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadTapped',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastTappedId, equals('default'));
    });

    testWidgets('updates lastClosedId when closed', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['bubble1']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadClosed',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastClosedId, equals('bubble1'));
    });

    testWidgets('updates lastExpandedId when expanded', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadExpanded',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastExpandedId, equals('default'));
    });

    testWidgets('updates lastCollapsedId when collapsed', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default']);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadCollapsed',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastCollapsedId, equals('default'));
    });

    testWidgets('updates lastDragStart when drag starts', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default', 10.0, 20.0]);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadDragStart',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastDragStart, isNotNull);
      expect(data!.lastDragStart!.x, equals(10.0));
    });

    testWidgets('updates lastDragEnd when drag ends', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec
          .encodeMessage(<Object?>['default', 100.0, 200.0]);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
            'FloatyOverlayFlutterApi.onChatHeadDragEnd',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.lastDragEnd, isNotNull);
      expect(data!.lastDragEnd!.x, equals(100.0));
    });

    testWidgets('updates palette when palette changes', (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final paletteMessage = {
        '__floaty__': '_floaty_theme',
        '_floaty_theme': {'primary': 0xFF6200EE},
      };
      final encoded = const JSONMessageCodec().encodeMessage(paletteMessage);
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      await tester.pump();
      expect(data!.palette, isNotNull);
    });

    testWidgets('updates isMainAppConnected on connection change',
        (tester) async {
      FloatyScopeData? data;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(
            child: Builder(
              builder: (context) {
                data = FloatyScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Simulate a disconnect.
      final encoded = const JSONMessageCodec().encodeMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': false},
      });
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );
      await tester.pump();
      expect(data!.isMainAppConnected, isFalse);

      // Simulate a reconnect.
      final encoded2 = const JSONMessageCodec().encodeMessage({
        '__floaty__': '_floaty_connection',
        '_floaty_connection': {'connected': true},
      });
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded2,
        (data) {},
      );
      await tester.pump();
      expect(data!.isMainAppConnected, isTrue);
    });

    testWidgets('disposes stream subscriptions on unmount', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyScope(child: SizedBox.shrink()),
        ),
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );
    });
  });

  group('FloatyScopeData', () {
    test('default constructor provides empty state', () {
      const data = FloatyScopeData();
      expect(data.lastMessage, isNull);
      expect(data.messages, isEmpty);
      expect(data.lastTappedId, isNull);
      expect(data.palette, isNull);
    });

    test('constructor accepts all fields', () {
      const event = ChatHeadDragEvent(id: 'default', x: 10, y: 20);
      const data = FloatyScopeData(
        lastMessage: 'hello',
        messages: ['hello', 'world'],
        lastTappedId: 'default',
        lastClosedId: 'bubble1',
        lastExpandedId: 'default',
        lastCollapsedId: 'bubble1',
        lastDragStart: event,
        lastDragEnd: event,
      );
      expect(data.lastMessage, equals('hello'));
      expect(data.messages.length, equals(2));
      expect(data.lastTappedId, equals('default'));
      expect(data.lastDragStart?.x, equals(10));
    });
  });
}
