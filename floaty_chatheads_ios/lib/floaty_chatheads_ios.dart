import 'dart:typed_data';

import 'package:floaty_chatheads_ios/src/chat_head_config_mapper.dart';
import 'package:floaty_chatheads_ios/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_ios/src/overlay_position_mapper.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_chatheads_ios}
/// The iOS implementation of [FloatyChatheadsPlatform].
///
/// Uses a `UIWindow`-based PiP overlay at `windowLevel = .alert + 1`, so no
/// special permissions are required. Android-only fields are deliberately
/// not forwarded: `ChatHeadAssets` and `AddChatHeadConfig.iconSource` (the
/// bubble is a Flutter view that renders its own icons; only `iconAsset` is
/// sent as a hint) and `NotificationConfig.description` (there is no
/// foreground service notification on iOS).
/// {@endtemplate}
final class FloatyChatheadsIOS extends FloatyChatheadsPlatform {
  /// {@macro floaty_chatheads_ios}
  factory FloatyChatheadsIOS() = FloatyChatheadsIOS._;

  FloatyChatheadsIOS._();

  final pigeon.FloatyHostApi _hostApi = pigeon.FloatyHostApi();
  final pigeon.FloatyOverlayHostApi _overlayHostApi =
      pigeon.FloatyOverlayHostApi();

  /// Registers this class as the default instance of
  /// [FloatyChatheadsPlatform].
  static void registerWith() {
    FloatyChatheadsPlatform.instance = FloatyChatheadsIOS();
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
  Future<void> addChatHead(AddChatHeadConfig config) => _hostApi.addChatHead(
    pigeon.AddChatHeadConfig(id: config.id, iconAsset: config.iconAsset),
  );

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
  bool get supportsNativeIcons => false;

  /// No-op: the iOS bubble is part of the overlay's Flutter view, so raw
  /// icon frames are never sent to native code.
  @override
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) async {}
}
