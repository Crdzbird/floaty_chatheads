import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFloatyChatheadsPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FloatyChatheadsPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheads', () {
    late MockFloatyChatheadsPlatform platform;

    setUp(() {
      platform = MockFloatyChatheadsPlatform();
      FloatyChatheadsPlatform.instance = platform;
    });

    setUpAll(() {
      registerFallbackValue(const ChatHeadConfig());
      registerFallbackValue(const AddChatHeadConfig(id: ''));
    });

    test('checkPermission delegates to platform', () async {
      when(() => platform.checkPermission()).thenAnswer((_) async => true);
      expect(await FloatyChatheads.checkPermission(), isTrue);
      verify(() => platform.checkPermission()).called(1);
    });

    test('requestPermission delegates to platform', () async {
      when(() => platform.requestPermission()).thenAnswer((_) async => true);
      expect(await FloatyChatheads.requestPermission(), isTrue);
    });

    test('showChatHead delegates to platform', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead();
      verify(() => platform.showChatHead(any())).called(1);
    });

    test('showChatHead passes config correctly', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead(
        entryPoint: 'myOverlay',
        contentWidth: 300,
        contentHeight: 400,
        debugMode: true,
        sizePreset: ContentSizePreset.card,
        snap: const SnapConfig(edge: SnapEdge.left),
      );
      final captured =
          verify(() => platform.showChatHead(captureAny())).captured;
      final config = captured.first as ChatHeadConfig;
      expect(config.entryPoint, equals('myOverlay'));
      expect(config.contentWidth, equals(300));
      expect(config.contentHeight, equals(400));
      expect(config.debugMode, isTrue);
      expect(config.sizePreset, equals(ContentSizePreset.card));
      expect(config.snap?.edge, equals(SnapEdge.left));
    });

    test('closeChatHead delegates to platform', () async {
      when(() => platform.closeChatHead()).thenAnswer((_) async {});
      await FloatyChatheads.closeChatHead();
      verify(() => platform.closeChatHead()).called(1);
    });

    test('isActive delegates to platform', () async {
      when(() => platform.isActive()).thenAnswer((_) async => false);
      expect(await FloatyChatheads.isActive(), isFalse);
    });

    test('addChatHead delegates to platform', () async {
      when(() => platform.addChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.addChatHead(id: 'bubble1');
      verify(() => platform.addChatHead(any())).called(1);
    });

    test('removeChatHead delegates to platform', () async {
      when(() => platform.removeChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.removeChatHead('bubble1');
      verify(() => platform.removeChatHead('bubble1')).called(1);
    });

    test('updateBadge delegates to platform', () async {
      when(() => platform.updateBadge(any())).thenAnswer((_) async {});
      await FloatyChatheads.updateBadge(5);
      verify(() => platform.updateBadge(5)).called(1);
    });

    test('expandChatHead delegates to platform', () async {
      when(() => platform.expandChatHead()).thenAnswer((_) async {});
      await FloatyChatheads.expandChatHead();
      verify(() => platform.expandChatHead()).called(1);
    });

    test('collapseChatHead delegates to platform', () async {
      when(() => platform.collapseChatHead()).thenAnswer((_) async {});
      await FloatyChatheads.collapseChatHead();
      verify(() => platform.collapseChatHead()).called(1);
    });

    test('shareData sends via BasicMessageChannel', () async {
      // shareData should not throw even without a native handler.
      await FloatyChatheads.shareData('test-data');
    });

    test('onData returns broadcast stream', () {
      FloatyChatheads.onData
        // Should be broadcast (allows multiple listeners).
        ..listen((_) {})
        ..listen((_) {});
    });

    test('onData message handler forwards data', () async {
      final values = <Object?>[];
      FloatyChatheads.onData.listen(values.add);

      // Simulate overlay sending data via the messenger channel.
      final encoded = const JSONMessageCodec().encodeMessage('overlay-msg');
      await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );

      await Future<void>.delayed(Duration.zero);
      expect(values, contains('overlay-msg'));
    });

    test('dispose detaches message handler', () {
      // Access onData to attach the handler.
      FloatyChatheads.onData;
      FloatyChatheads.dispose();
      // Should not throw.
      FloatyChatheads.dispose();
    });

    group('onClosed', () {
      tearDown(FloatyChatheads.dispose);

      test('returns a broadcast stream', () {
        FloatyChatheads.onClosed
          ..listen((_) {})
          ..listen((_) {});
      });

      test('emits chathead ID from system envelope', () async {
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        // Simulate the native side sending a closed event.
        final encoded = const JSONMessageCodec().encodeMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'bubble1'},
        });
        await TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .handlePlatformMessage(
          'ni.devotion.floaty_head/messenger',
          encoded,
          (data) {},
        );

        await Future<void>.delayed(Duration.zero);
        expect(ids, ['bubble1']);
      });

      test('defaults to "default" when id is absent', () async {
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        final encoded = const JSONMessageCodec().encodeMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': <String, dynamic>{},
        });
        await TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .handlePlatformMessage(
          'ni.devotion.floaty_head/messenger',
          encoded,
          (data) {},
        );

        await Future<void>.delayed(Duration.zero);
        expect(ids, ['default']);
      });

      test('dispose unregisters handler and stops emitting', () async {
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        FloatyChatheads.dispose();

        // Send another closed event — should NOT arrive.
        final encoded = const JSONMessageCodec().encodeMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'bubble2'},
        });
        await TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .handlePlatformMessage(
          'ni.devotion.floaty_head/messenger',
          encoded,
          (data) {},
        );

        await Future<void>.delayed(Duration.zero);
        expect(ids, isEmpty);
      });

      test('re-attaches handler after dispose + re-access', () async {
        // First access + dispose.
        FloatyChatheads.onClosed;
        FloatyChatheads.dispose();

        // Re-access should re-attach.
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        final encoded = const JSONMessageCodec().encodeMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'bubble3'},
        });
        await TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .handlePlatformMessage(
          'ni.devotion.floaty_head/messenger',
          encoded,
          (data) {},
        );

        await Future<void>.delayed(Duration.zero);
        expect(ids, ['bubble3']);
      });
    });
  });
}
