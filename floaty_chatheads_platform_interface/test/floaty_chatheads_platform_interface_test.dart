import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class FloatyChatheadsMock extends FloatyChatheadsPlatform {
  @override
  Future<bool> checkPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showChatHead(ChatHeadConfig config) async {}

  @override
  Future<void> closeChatHead() async {}

  @override
  Future<bool> isActive() async => false;

  @override
  Future<void> addChatHead(AddChatHeadConfig config) async {}

  @override
  Future<void> removeChatHead(String id) async {}

  @override
  Future<void> resizeContent(int width, int height) async {}

  @override
  Future<void> updateFlag(OverlayFlag flag) async {}

  @override
  Future<void> closeOverlay() async {}

  @override
  Future<OverlayPosition> getOverlayPosition() async =>
      const OverlayPosition(x: 10, y: 20);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheadsPlatformInterface', () {
    late FloatyChatheadsPlatform platform;

    setUp(() {
      platform = FloatyChatheadsMock();
      FloatyChatheadsPlatform.instance = platform;
    });

    test('checkPermission returns true', () async {
      expect(await platform.checkPermission(), isTrue);
    });

    test('requestPermission returns true', () async {
      expect(await platform.requestPermission(), isTrue);
    });

    test('isActive returns false', () async {
      expect(await platform.isActive(), isFalse);
    });

    test('getOverlayPosition returns correct coordinates', () async {
      final pos = await platform.getOverlayPosition();
      expect(pos.x, equals(10));
      expect(pos.y, equals(20));
    });

    test('default implementation throws UnimplementedError', () {
      final defaultPlatform = _DefaultPlatform();
      expect(defaultPlatform.checkPermission, throwsUnimplementedError);
      expect(defaultPlatform.requestPermission, throwsUnimplementedError);
      expect(
        () => defaultPlatform.showChatHead(const ChatHeadConfig()),
        throwsUnimplementedError,
      );
      expect(defaultPlatform.closeChatHead, throwsUnimplementedError);
      expect(defaultPlatform.isActive, throwsUnimplementedError);
      expect(
        () => defaultPlatform.addChatHead(
          const AddChatHeadConfig(id: 'test'),
        ),
        throwsUnimplementedError,
      );
      expect(
        () => defaultPlatform.removeChatHead('test'),
        throwsUnimplementedError,
      );
      expect(
        () => defaultPlatform.resizeContent(100, 100),
        throwsUnimplementedError,
      );
      expect(
        () => defaultPlatform.updateFlag(OverlayFlag.defaultFlag),
        throwsUnimplementedError,
      );
      expect(defaultPlatform.closeOverlay, throwsUnimplementedError);
      expect(defaultPlatform.getOverlayPosition, throwsUnimplementedError);
    });
  });
}

class _DefaultPlatform extends FloatyChatheadsPlatform {}
