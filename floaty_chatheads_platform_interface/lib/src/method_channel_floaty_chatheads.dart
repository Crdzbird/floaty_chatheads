import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// {@template method_channel_floaty_chatheads}
/// Fallback [FloatyChatheadsPlatform] implementation using method channels.
///
/// Platform packages (Android/iOS) override this with their own
/// Pigeon-based implementations at registration time.
/// {@endtemplate}
class MethodChannelFloatyChatheads extends FloatyChatheadsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('floaty_chatheads');

  /// {@macro floaty_chatheads_platform.check_permission}
  @override
  Future<bool> checkPermission() async {
    final result = await methodChannel.invokeMethod<bool>('checkPermission');
    return result ?? false;
  }

  /// {@macro floaty_chatheads_platform.request_permission}
  @override
  Future<bool> requestPermission() async {
    final result = await methodChannel.invokeMethod<bool>('requestPermission');
    return result ?? false;
  }

  /// {@macro floaty_chatheads_platform.show_chat_head}
  @override
  Future<void> showChatHead(ChatHeadConfig config) {
    // Resolve size preset: if set, use preset dimensions;
    // otherwise use raw values.
    final effectiveWidth =
        config.sizePreset?.width ?? config.contentWidth;
    final effectiveHeight =
        config.sizePreset?.height ?? config.contentHeight;

    return methodChannel.invokeMethod<void>('showChatHead', {
      'entryPoint': config.entryPoint,
      'contentWidth': effectiveWidth,
      'contentHeight': effectiveHeight,
      if (config.assets?.icon != null)
        'chatheadIconSource':
            _serializeIconSource(config.assets!.icon),
      if (config.assets?.closeIcon != null)
        'closeIconSource':
            _serializeIconSource(config.assets!.closeIcon),
      if (config.assets?.closeBackground != null)
        'closeBackgroundSource':
            _serializeIconSource(config.assets!.closeBackground),
      'notificationTitle': config.notification?.title,
      'notificationDescription': config.notification?.description,
      'notificationIconAsset': config.notification?.iconAsset,
      'flag': config.flag.index,
      'enableDrag': config.enableDrag,
      'notificationVisibility':
          (config.notification?.visibility ??
              NotificationVisibility.visibilityPublic)
              .index,
      'snapEdge': (config.snap?.edge ?? SnapEdge.both).index,
      'snapMargin': config.snap?.margin ?? -10,
      'persistPosition': config.snap?.persistPosition ?? false,
      'entranceAnimation': config.entranceAnimation.index,
      'debugMode': config.debugMode,
      'autoLaunchOnBackground': config.autoLaunchOnBackground,
      'persistOnAppClose': config.persistOnAppClose,
      if (config.theme != null)
        'theme': {
          'badgeColor': config.theme!.badgeColor,
          'badgeTextColor': config.theme!.badgeTextColor,
          'bubbleBorderColor': config.theme!.bubbleBorderColor,
          'bubbleBorderWidth': config.theme!.bubbleBorderWidth,
          'bubbleShadowColor': config.theme!.bubbleShadowColor,
          'closeTintColor': config.theme!.closeTintColor,
          if (config.theme!.overlayPalette != null)
            'overlayPalette': config.theme!.overlayPalette,
        },
    });
  }

  /// {@macro floaty_chatheads_platform.close_chat_head}
  @override
  Future<void> closeChatHead() {
    return methodChannel.invokeMethod<void>('closeChatHead');
  }

  /// {@macro floaty_chatheads_platform.is_active}
  @override
  Future<bool> isActive() async {
    final result = await methodChannel.invokeMethod<bool>('isActive');
    return result ?? false;
  }

  /// {@macro floaty_chatheads_platform.add_chat_head}
  @override
  Future<void> addChatHead(AddChatHeadConfig config) {
    return methodChannel.invokeMethod<void>('addChatHead', {
      'id': config.id,
      'iconAsset': config.iconAsset,
      if (config.iconSource != null)
        'iconSource': _serializeIconSource(config.iconSource!),
    });
  }

  /// {@macro floaty_chatheads_platform.remove_chat_head}
  @override
  Future<void> removeChatHead(String id) {
    return methodChannel.invokeMethod<void>('removeChatHead', {'id': id});
  }

  /// {@macro floaty_chatheads_platform.resize_content}
  @override
  Future<void> resizeContent(int width, int height) {
    return methodChannel.invokeMethod<void>('resizeContent', {
      'width': width,
      'height': height,
    });
  }

  /// {@macro floaty_chatheads_platform.update_flag}
  @override
  Future<void> updateFlag(OverlayFlag flag) {
    return methodChannel.invokeMethod<void>('updateFlag', {
      'flag': flag.index,
    });
  }

  /// {@macro floaty_chatheads_platform.close_overlay}
  @override
  Future<void> closeOverlay() {
    return methodChannel.invokeMethod<void>('closeOverlay');
  }

  /// {@macro floaty_chatheads_platform.get_overlay_position}
  @override
  Future<OverlayPosition> getOverlayPosition() async {
    final result = await methodChannel
        .invokeMapMethod<String, double>('getOverlayPosition');
    return OverlayPosition(
      x: result?['x'] ?? 0,
      y: result?['y'] ?? 0,
    );
  }

  /// {@macro floaty_chatheads_platform.update_badge}
  @override
  Future<void> updateBadge(int count) {
    return methodChannel.invokeMethod<void>('updateBadge', {'count': count});
  }

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  @override
  Future<void> expandChatHead() {
    return methodChannel.invokeMethod<void>('expandChatHead');
  }

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  @override
  Future<void> collapseChatHead() {
    return methodChannel.invokeMethod<void>('collapseChatHead');
  }

  /// {@macro floaty_chatheads_platform.update_chat_head_icon}
  @override
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) {
    return methodChannel.invokeMethod<void>('updateChatHeadIcon', {
      'id': id,
      'rgbaBytes': rgbaBytes,
      'width': width,
      'height': height,
    });
  }

  static Map<String, Object?> _serializeIconSource(IconSource source) {
    return switch (source) {
      AssetIconSource(:final path) => {
          'type': 'asset',
          'path': path,
        },
      NetworkIconSource(:final url) => {
          'type': 'network',
          'path': url,
        },
      BytesIconSource(:final data) => {
          'type': 'bytes',
          'bytes': data,
        },
    };
  }
}
