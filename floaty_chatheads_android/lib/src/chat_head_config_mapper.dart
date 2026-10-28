import 'package:floaty_chatheads_android/src/chat_head_theme_mapper.dart';
import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_android/src/icon_source_mapper.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Converts a platform-interface [ChatHeadConfig] to its Pigeon message.
extension ChatHeadConfigMapper on ChatHeadConfig {
  /// Returns the [pigeon.ChatHeadConfig] sent to the Kotlin host API.
  pigeon.ChatHeadConfig toPigeonConfig() {
    final size = ChatHeadConfigResolver.contentSize(this);
    final visibility = ChatHeadConfigResolver.notificationVisibility(
      notification,
    );
    final edge = ChatHeadConfigResolver.snapEdge(snap);
    return pigeon.ChatHeadConfig(
      entryPoint: entryPoint,
      entryPointLibrary: entryPointLibrary,
      contentWidth: size.width,
      contentHeight: size.height,
      notificationTitle: notification?.title,
      notificationDescription: notification?.description,
      notificationIconAsset: notification?.iconAsset,
      flag: pigeon.OverlayFlagMessage.values[flag.index],
      enableDrag: enableDrag,
      notificationVisibility:
          pigeon.NotificationVisibilityMessage.values[visibility.index],
      snapEdge: pigeon.SnapEdgeMessage.values[edge.index],
      snapMargin: ChatHeadConfigResolver.snapMargin(snap),
      persistPosition: ChatHeadConfigResolver.persistPosition(snap),
      entranceAnimation:
          pigeon.EntranceAnimationMessage.values[entranceAnimation.index],
      panelAnchor: pigeon.PanelAnchorMessage.values[panelAnchor.index],
      theme: theme?.toPigeonTheme(),
      debugMode: debugMode,
      autoLaunchOnBackground: autoLaunchOnBackground,
      persistOnAppClose: persistOnAppClose,
      chatheadIconSource: assets?.icon.toPigeonIconSource(),
      closeIconSource: assets?.closeIcon.toPigeonIconSource(),
      closeBackgroundSource: assets?.closeBackground.toPigeonIconSource(),
    );
  }
}
