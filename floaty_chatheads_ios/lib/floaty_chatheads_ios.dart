import 'dart:typed_data';

import 'package:floaty_chatheads_ios/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_chatheads_ios}
/// The iOS implementation of [FloatyChatheadsPlatform].
///
/// Uses a `UIWindow`-based PiP overlay at `windowLevel = .alert + 1`
/// instead of system-level overlays. No special permissions are required.
///
/// ### iOS-specific platform behavior
///
/// The iOS chathead renders entirely through a Flutter engine attached to
/// a `UIWindow`, which means several Android-only knobs are deliberately
/// not forwarded to native code:
///
/// - `ChatHeadAssets` (icon / closeIcon / closeBackground) — the chathead
///   bubble is a Flutter view, so app authors render their own icons
///   inside the overlay entry point. The Swift side does not consume
///   `IconSource` payloads.
/// - `NotificationConfig.description` — there is no foreground-service
///   notification on iOS.
/// - `AddChatHeadConfig.iconSource` — secondary bubbles are also Flutter
///   views; only `iconAsset` is forwarded as a hint.
///
/// These omissions are intentional. Wiring the fields through would
/// silently send data into a void.
/// {@endtemplate}
class FloatyChatheadsIOS extends FloatyChatheadsPlatform {
  /// Pigeon host API for main-app operations.
  final pigeon.FloatyHostApi _hostApi = pigeon.FloatyHostApi();

  /// Pigeon host API for overlay-side operations.
  final pigeon.FloatyOverlayHostApi _overlayHostApi =
      pigeon.FloatyOverlayHostApi();

  /// Registers this class as the default instance of
  /// [FloatyChatheadsPlatform].
  static void registerWith() {
    FloatyChatheadsPlatform.instance = FloatyChatheadsIOS();
  }

  /// {@macro floaty_chatheads_platform.check_permission}
  @override
  Future<bool> checkPermission() => _hostApi.checkPermission();

  /// {@macro floaty_chatheads_platform.request_permission}
  @override
  Future<bool> requestPermission() => _hostApi.requestPermission();

  /// {@macro floaty_chatheads_platform.show_chat_head}
  ///
  /// On iOS, `config.assets` (icon overrides) and
  /// `config.notification.description` are intentionally not forwarded —
  /// see the class-level docs for why.
  @override
  Future<void> showChatHead(ChatHeadConfig config) {
    final size = ChatHeadConfigResolver.contentSize(config);
    return _hostApi.showChatHead(
      pigeon.ChatHeadConfig(
        entryPoint: config.entryPoint,
        contentWidth: size.width,
        contentHeight: size.height,
        notificationTitle: config.notification?.title,
        notificationIconAsset: config.notification?.iconAsset,
        flag: pigeon.OverlayFlagMessage.values[config.flag.index],
        enableDrag: config.enableDrag,
        notificationVisibility: pigeon.NotificationVisibilityMessage.values[
            ChatHeadConfigResolver.notificationVisibility(config.notification)
                .index],
        snapEdge: pigeon.SnapEdgeMessage
            .values[ChatHeadConfigResolver.snapEdge(config.snap).index],
        snapMargin: ChatHeadConfigResolver.snapMargin(config.snap),
        persistPosition: ChatHeadConfigResolver.persistPosition(config.snap),
        entranceAnimation: pigeon
            .EntranceAnimationMessage.values[config.entranceAnimation.index],
        theme: _toThemeMessage(config.theme),
        debugMode: config.debugMode,
        autoLaunchOnBackground: config.autoLaunchOnBackground,
        persistOnAppClose: config.persistOnAppClose,
      ),
    );
  }

  static pigeon.ChatHeadThemeMessage? _toThemeMessage(ChatHeadTheme? t) {
    if (t == null) return null;
    return pigeon.ChatHeadThemeMessage(
      badgeColor: t.badgeColor,
      badgeTextColor: t.badgeTextColor,
      bubbleBorderColor: t.bubbleBorderColor,
      bubbleBorderWidth: t.bubbleBorderWidth,
      bubbleShadowColor: t.bubbleShadowColor,
      closeTintColor: t.closeTintColor,
      overlayPalette: t.overlayPalette != null
          ? Map<String?, int?>.from(t.overlayPalette!)
          : null,
    );
  }

  /// {@macro floaty_chatheads_platform.close_chat_head}
  @override
  Future<void> closeChatHead() => _hostApi.closeChatHead();

  /// {@macro floaty_chatheads_platform.is_active}
  @override
  Future<bool> isActive() => _hostApi.isChatHeadActive();

  /// {@macro floaty_chatheads_platform.add_chat_head}
  @override
  Future<void> addChatHead(AddChatHeadConfig config) {
    return _hostApi.addChatHead(
      pigeon.AddChatHeadConfig(id: config.id, iconAsset: config.iconAsset),
    );
  }

  /// {@macro floaty_chatheads_platform.remove_chat_head}
  @override
  Future<void> removeChatHead(String id) => _hostApi.removeChatHead(id);

  /// {@macro floaty_chatheads_platform.resize_content}
  @override
  Future<void> resizeContent(int width, int height) =>
      _overlayHostApi.resizeContent(width, height);

  /// {@macro floaty_chatheads_platform.update_flag}
  @override
  Future<void> updateFlag(OverlayFlag flag) =>
      _overlayHostApi.updateFlag(pigeon.OverlayFlagMessage.values[flag.index]);

  /// {@macro floaty_chatheads_platform.close_overlay}
  @override
  Future<void> closeOverlay() => _overlayHostApi.closeOverlay();

  /// {@macro floaty_chatheads_platform.get_overlay_position}
  @override
  Future<OverlayPosition> getOverlayPosition() async {
    final pos = await _overlayHostApi.getOverlayPosition();
    return OverlayPosition(x: pos.x, y: pos.y);
  }

  /// {@macro floaty_chatheads_platform.update_badge}
  @override
  Future<void> updateBadge(int count) => _hostApi.updateBadge(count);

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  @override
  Future<void> expandChatHead() => _hostApi.expandChatHead();

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  @override
  Future<void> collapseChatHead() => _hostApi.collapseChatHead();

  @override
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) =>
      _hostApi.updateChatHeadIcon(id, rgbaBytes, width, height);
}
