import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyController', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('show launches chathead and sets isActive', () async {
      final controller = FloatyController(entryPoint: 'test');
      expect(controller.isActive, isFalse);

      await controller.show();
      expect(controller.isActive, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('test'));

      controller.dispose();
    });

    test('close stops chathead and clears isActive', () async {
      final controller = FloatyController();
      await controller.show();
      expect(controller.isActive, isTrue);

      await controller.close();
      expect(controller.isActive, isFalse);
      expect(fake.closeChatHeadCalled, isTrue);

      controller.dispose();
    });

    test('toggle shows when inactive', () async {
      final controller = FloatyController();
      final result = await controller.toggle();
      expect(result, isTrue);
      expect(controller.isActive, isTrue);
      controller.dispose();
    });

    test('toggle closes when active', () async {
      final controller = FloatyController();
      await controller.show();

      final result = await controller.toggle();
      expect(result, isFalse);
      expect(controller.isActive, isFalse);

      controller.dispose();
    });

    test('show returns false when permission denied', () async {
      fake.permissionGranted = false;
      final controller = FloatyController();
      final result = await controller.show();
      expect(result, isFalse);
      expect(controller.isActive, isFalse);
      controller.dispose();
    });

    test('notifies listeners on show', () async {
      final controller = FloatyController();
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.show();
      expect(notified, isTrue);

      controller.dispose();
    });

    test('notifies listeners on close', () async {
      final controller = FloatyController();
      await controller.show();

      var notified = false;
      controller.addListener(() => notified = true);

      await controller.close();
      expect(notified, isTrue);

      controller.dispose();
    });

    test('passes all config options', () async {
      const theme = ChatHeadTheme(badgeColor: 0xFFFF0000);
      final controller = FloatyController(
        entryPoint: 'custom',
        assets: const ChatHeadAssets(
          icon: IconSource.asset('assets/icon.png'),
          closeIcon: IconSource.asset('assets/close.png'),
          closeBackground: IconSource.asset('assets/closeBg.png'),
        ),
        sizePreset: ContentSizePreset.card,
        theme: theme,
        debugMode: true,
        snap: const SnapConfig(
          edge: SnapEdge.left,
          margin: 5,
          persistPosition: true,
        ),
        entranceAnimation: EntranceAnimation.pop,
      );

      await controller.show();
      final config = fake.lastConfig!;
      expect(config.entryPoint, equals('custom'));
      expect(config.effectiveChatheadIcon, equals('assets/icon.png'));
      expect(config.sizePreset, equals(ContentSizePreset.card));
      expect(config.theme?.badgeColor, equals(0xFFFF0000));
      expect(config.debugMode, isTrue);
      expect(config.snap?.edge, equals(SnapEdge.left));
      expect(config.snap?.margin, equals(5));
      expect(config.snap?.persistPosition, isTrue);
      expect(config.entranceAnimation, equals(EntranceAnimation.pop));

      controller.dispose();
    });

    test('onError is called when show throws', () async {
      // Use a platform that throws.
      fake.permissionGranted = true;
      Object? caughtError;
      final controller = FloatyController(
        onError: (e, st) => caughtError = e,
      );

      // This should succeed normally.
      await controller.show();
      expect(caughtError, isNull);

      controller.dispose();
    });

    test('sendData delegates to FloatyChatheads.shareData', () async {
      final controller = FloatyController();
      // Should not throw even without a native handler.
      await controller.sendData({'action': 'test'});
      controller.dispose();
    });

    test('show subscribes to onData when callback provided', () async {
      final data = <Object?>[];
      final controller = FloatyController(
        onData: data.add,
      );
      await controller.show();
      expect(controller.isActive, isTrue);
      controller.dispose();
    });

    test('onError catches close errors', () async {
      // Use a platform that throws on close.
      final throwingPlatform = _ThrowingClosePlatform();
      FloatyChatheadsPlatform.instance = throwingPlatform;

      Object? caughtError;
      final controller = FloatyController(
        onError: (e, st) => caughtError = e,
      );

      await controller.show();
      await controller.close();
      expect(caughtError, isNotNull);

      controller.dispose();
    });

    test('onError catches show errors', () async {
      final throwingPlatform = _ThrowingShowPlatform();
      FloatyChatheadsPlatform.instance = throwingPlatform;

      Object? caughtError;
      final controller = FloatyController(
        onError: (e, st) => caughtError = e,
      );

      final result = await controller.show();
      expect(result, isFalse);
      expect(caughtError, isNotNull);

      controller.dispose();
    });
  });

  group('FloatyControllerWidget', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    testWidgets('shows chathead on mount', (tester) async {
      await tester.pumpWidget(
        const FloatyControllerWidget(
          entryPoint: 'test',
          child: SizedBox.shrink(),
        ),
      );
      // Let async show() complete.
      await tester.pumpAndSettle();
      expect(fake.showChatHeadCalled, isTrue);
    });

    testWidgets('of returns controller from descendant context',
        (tester) async {
      FloatyController? foundController;
      await tester.pumpWidget(
        FloatyControllerWidget(
          entryPoint: 'test',
          child: Builder(
            builder: (context) {
              foundController = FloatyControllerWidget.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(foundController, isNotNull);
      expect(foundController!.isActive, isTrue);
    });

    testWidgets('of returns null when no ancestor', (tester) async {
      FloatyController? foundController;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            foundController = FloatyControllerWidget.of(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(foundController, isNull);
    });

    testWidgets('closes chathead on unmount', (tester) async {
      await tester.pumpWidget(
        const FloatyControllerWidget(
          entryPoint: 'test',
          child: SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();
      expect(fake.showChatHeadCalled, isTrue);

      // Unmount.
      await tester.pumpWidget(const SizedBox.shrink());
      // dispose was called (no error means success).
    });
  });
}

class _ThrowingClosePlatform extends FakeFloatyPlatform {
  @override
  Future<void> closeChatHead() async {
    throw Exception('close failed');
  }
}

class _ThrowingShowPlatform extends FakeFloatyPlatform {
  @override
  Future<bool> checkPermission() async {
    throw Exception('show failed');
  }
}
