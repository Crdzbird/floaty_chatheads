import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_chatheads_android}
/// The Android implementation of [FloatyChatheadsPlatform].
///
/// Uses Pigeon-generated APIs for type-safe communication with Kotlin.
/// The overlay runs as a foreground service with `SYSTEM_ALERT_WINDOW`.
/// {@endtemplate}
class FloatyChatheadsAndroid extends FloatyChatheadsPlatform {
  /// Pigeon host API for main-app operations.
  final pigeon.FloatyHostApi _hostApi = pigeon.FloatyHostApi();

  /// Pigeon host API for overlay-side operations.
  final pigeon.FloatyOverlayHostApi _overlayHostApi =
      pigeon.FloatyOverlayHostApi();

  /// Registers this class as the default instance of
  /// [FloatyChatheadsPlatform].
  static void registerWith() {
    FloatyChatheadsPlatform.instance = FloatyChatheadsAndroid();
  }

  /// {@macro floaty_chatheads_platform.check_permission}
  @override
  Future<bool> checkPermission() => _hostApi.checkPermission();

  /// {@macro floaty_chatheads_platform.request_permission}
  @override
  Future<bool> requestPermission() => _hostApi.requestPermission();

  /// {@macro floaty_chatheads_platform.show_chat_head}
  @override
  Future<void> showChatHead(ChatHeadConfig config) {
    // Resolve size preset: if set, use preset dimensions;
    // otherwise use raw values.
    final effectiveWidth = config.sizePreset?.width ?? config.contentWidth;
    final effectiveHeight = config.sizePreset?.height ?? config.contentHeight;

    // Build theme message if theme is provided.
    pigeon.ChatHeadThemeMessage? themeMsg;
    if (config.theme != null) {
      final t = config.theme!;
      themeMsg = pigeon.ChatHeadThemeMessage(
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

    return _hostApi.showChatHead(
      pigeon.ChatHeadConfig(
        entryPoint: config.entryPoint,
        contentWidth: effectiveWidth,
        contentHeight: effectiveHeight,
        chatheadIconAsset: config.effectiveChatheadIcon,
        closeIconAsset: config.effectiveCloseIcon,
        closeBackgroundAsset: config.effectiveCloseBackground,
        notificationTitle: config.effectiveNotificationTitle,
        notificationDescription: config.effectiveNotificationDescription,
        notificationIconAsset: config.effectiveNotificationIcon,
        flag: pigeon.OverlayFlagMessage.values[config.flag.index],
        enableDrag: config.enableDrag,
        notificationVisibility: pigeon.NotificationVisibilityMessage
            .values[config.effectiveNotificationVisibility.index],
        snapEdge: pigeon.SnapEdgeMessage
            .values[config.effectiveSnapEdge.index],
        snapMargin: config.effectiveSnapMargin,
        persistPosition: config.effectivePersistPosition,
        entranceAnimation: pigeon.EntranceAnimationMessage
            .values[config.entranceAnimation.index],
        theme: themeMsg,
        debugMode: config.debugMode,
        chatheadIconSource: _toIconSourceMessage(
          config.effectiveChatheadIconSource,
        ),
        closeIconSource: _toIconSourceMessage(
          config.effectiveCloseIconSource,
        ),
        closeBackgroundSource: _toIconSourceMessage(
          config.effectiveCloseBackgroundSource,
        ),
      ),
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
      pigeon.AddChatHeadConfig(
        id: config.id,
        iconAsset: config.iconAsset,
        iconSource: config.iconSource != null
            ? _toIconSourceMessage(config.iconSource)
            : (config.iconAsset != null
                ? _toIconSourceMessage(IconSource.asset(config.iconAsset!))
                : null),
      ),
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

  /// Converts a platform-interface [IconSource] to a Pigeon
  /// [pigeon.IconSourceMessage].
  static pigeon.IconSourceMessage? _toIconSourceMessage(IconSource? source) {
    if (source == null) return null;
    return switch (source) {
      AssetIconSource(:final path) => pigeon.IconSourceMessage(
          type: pigeon.IconSourceTypeMessage.asset,
          path: path,
        ),
      NetworkIconSource(:final url) => pigeon.IconSourceMessage(
          type: pigeon.IconSourceTypeMessage.network,
          path: url,
        ),
      BytesIconSource(:final data) => pigeon.IconSourceMessage(
          type: pigeon.IconSourceTypeMessage.bytes,
          bytes: data,
        ),
    };
  }
}
