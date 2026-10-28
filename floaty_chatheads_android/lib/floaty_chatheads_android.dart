import 'dart:typed_data';

import 'package:floaty_chatheads_android/src/add_chat_head_config_mapper.dart';
import 'package:floaty_chatheads_android/src/chat_head_config_mapper.dart';
import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_android/src/overlay_position_mapper.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_chatheads_android}
/// The Android implementation of [FloatyChatheadsPlatform].
///
/// Uses Pigeon-generated APIs for type-safe communication with Kotlin.
/// The overlay runs as a foreground service with `SYSTEM_ALERT_WINDOW`.
/// {@endtemplate}
final class FloatyChatheadsAndroid extends FloatyChatheadsPlatform {
  /// {@macro floaty_chatheads_android}
  factory FloatyChatheadsAndroid() = FloatyChatheadsAndroid._;

  FloatyChatheadsAndroid._();

  final pigeon.FloatyHostApi _hostApi = pigeon.FloatyHostApi();
  final pigeon.FloatyOverlayHostApi _overlayHostApi =
      pigeon.FloatyOverlayHostApi();

  /// Registers this class as the default instance of
  /// [FloatyChatheadsPlatform].
  static void registerWith() {
    FloatyChatheadsPlatform.instance = FloatyChatheadsAndroid();
  }

  @override
  Future<bool> checkPermission() => _hostApi.checkPermission();

  @override
  Future<bool> requestPermission() => _hostApi.requestPermission();

  @override
  Future<void> showChatHead(ChatHeadConfig config) async {
    await _hostApi.showChatHead(config.toPigeonConfig());
    await OverlayReadiness.ensureReady(
      config,
      closeOverlay: _hostApi.closeChatHead,
    );
  }

  @override
  Future<void> closeChatHead() => _hostApi.closeChatHead();

  @override
  Future<bool> isActive() => _hostApi.isChatHeadActive();

  @override
  Future<void> addChatHead(AddChatHeadConfig config) =>
      _hostApi.addChatHead(config.toPigeonAddConfig());

  @override
  Future<void> removeChatHead(String id) => _hostApi.removeChatHead(id);

  @override
  Future<void> resizeContent(int width, int height) =>
      _overlayHostApi.resizeContent(width, height);

  @override
  Future<void> updateFlag(OverlayFlag flag) =>
      _overlayHostApi.updateFlag(flag.index);

  @override
  Future<void> closeOverlay() => _overlayHostApi.closeOverlay();

  @override
  Future<OverlayPosition> getOverlayPosition() async =>
      (await _overlayHostApi.getOverlayPosition()).toOverlayPosition();

  @override
  Future<void> updateBadge(int count) => _hostApi.updateBadge(count);

  @override
  Future<void> expandChatHead() => _hostApi.expandChatHead();

  @override
  Future<void> collapseChatHead() => _hostApi.collapseChatHead();

  @override
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) => _hostApi.updateChatHeadIcon(id, rgbaBytes, width, height);
}
