import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

final class FloatyChatheadsMock extends FloatyChatheadsPlatform {
  factory FloatyChatheadsMock() = FloatyChatheadsMock._;

  FloatyChatheadsMock._();

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
