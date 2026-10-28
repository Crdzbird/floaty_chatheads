import 'dart:typed_data';

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Builds the argument maps sent by the method channel fallback.
abstract final class MethodChannelArguments {
  /// Arguments for `showChatHead`, with any size preset applied.
  static Map<String, Object?> showChatHead(ChatHeadConfig config) => {
    'entryPoint': config.entryPoint,
    'entryPointLibrary': config.entryPointLibrary,
    'contentWidth': config.sizePreset?.width ?? config.contentWidth,
    'contentHeight': config.sizePreset?.height ?? config.contentHeight,
    ..._assets(config.assets),
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
    'panelAnchor': config.panelAnchor.index,
    'debugMode': config.debugMode,
    'autoLaunchOnBackground': config.autoLaunchOnBackground,
    'persistOnAppClose': config.persistOnAppClose,
    if (config.theme case final theme?) 'theme': _theme(theme),
  };

  /// Arguments for `addChatHead`.
  static Map<String, Object?> addChatHead(AddChatHeadConfig config) => {
    'id': config.id,
    'iconAsset': config.iconAsset,
    if (config.iconSource case final source?) 'iconSource': iconSource(source),
  };

  /// Serializes an [IconSource] into its wire form.
  static Map<String, Object?> iconSource(IconSource source) => switch (source) {
    AssetIconSource(:final path) => {'type': 'asset', 'path': path},
    NetworkIconSource(:final url) => {'type': 'network', 'path': url},
    BytesIconSource(:final data) => {'type': 'bytes', 'bytes': data},
  };

  /// Arguments for `updateChatHeadIcon`.
  static Map<String, Object?> chatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) => {'id': id, 'rgbaBytes': rgbaBytes, 'width': width, 'height': height};

  /// Reads the `getOverlayPosition` reply, defaulting missing values to 0.
  static OverlayPosition overlayPosition(Map<String, double>? result) =>
      OverlayPosition(x: result?['x'] ?? 0, y: result?['y'] ?? 0);

  static Map<String, Object?> _assets(ChatHeadAssets? assets) => {
    if (assets != null) ...{
      'chatheadIconSource': iconSource(assets.icon),
      'closeIconSource': iconSource(assets.closeIcon),
      'closeBackgroundSource': iconSource(assets.closeBackground),
    },
  };

  static Map<String, Object?> _theme(ChatHeadTheme theme) => {
    'badgeColor': theme.badgeColor,
    'badgeTextColor': theme.badgeTextColor,
    'bubbleBorderColor': theme.bubbleBorderColor,
    'bubbleBorderWidth': theme.bubbleBorderWidth,
    'bubbleShadowColor': theme.bubbleShadowColor,
    'closeTintColor': theme.closeTintColor,
    'overlayPalette': ?theme.overlayPalette,
  };
}
