import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_chatheads}
/// Main app API for controlling the floating chathead.
///
/// Use this from the main app isolate to show/close the chathead
/// and exchange data with the overlay. All methods are static.
///
/// ```dart
/// await FloatyChatheads.showChatHead(
///   entryPoint: 'overlayMain',
///   chatheadIconAsset: 'assets/chatheadIcon.png',
/// );
/// ```
/// {@endtemplate}
final class FloatyChatheads {
  FloatyChatheads._(); // coverage:ignore-line

  static FloatyChatheadsPlatform get _platform =>
      FloatyChatheadsPlatform.instance;

  /// {@template floaty_chatheads.on_data}
  /// Stream of messages sent from the overlay isolate.
  ///
  /// Attaches the message handler lazily on first access.
  /// {@endtemplate}
  static Stream<Object?> get onData => FloatyChannel.rawMessages;

  /// {@macro floaty_chatheads_platform.check_permission}
  static Future<bool> checkPermission() => _platform.checkPermission();

  /// {@macro floaty_chatheads_platform.request_permission}
  static Future<bool> requestPermission() => _platform.requestPermission();

  /// {@macro floaty_chatheads_platform.show_chat_head}
  ///
  /// See [ChatHeadConfig] for the full list of configuration options.
  ///
  /// Prefer [assets], [notification], and [snap] over their individual
  /// counterparts — the flat parameters are deprecated and will be
  /// removed in the next major version.
  static Future<void> showChatHead({
    String entryPoint = 'overlayMain',
    int? contentWidth,
    int? contentHeight,
    @Deprecated('Use assets instead') String? chatheadIconAsset,
    @Deprecated('Use assets instead') String? closeIconAsset,
    @Deprecated('Use assets instead') String? closeBackgroundAsset,
    @Deprecated('Use notification instead') String? notificationTitle,
    @Deprecated('Use notification instead') String? notificationIconAsset,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    @Deprecated('Use notification instead')
    NotificationVisibility notificationVisibility =
        NotificationVisibility.visibilityPublic,
    @Deprecated('Use snap instead') SnapEdge snapEdge = SnapEdge.both,
    @Deprecated('Use snap instead') double snapMargin = -10,
    @Deprecated('Use snap instead') bool persistPosition = false,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    ChatHeadTheme? theme,
    ContentSizePreset? sizePreset,
    bool debugMode = false,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
  }) {
    return _platform.showChatHead(
      ChatHeadConfig(
        entryPoint: entryPoint,
        contentWidth: contentWidth,
        contentHeight: contentHeight,
        chatheadIconAsset: chatheadIconAsset,
        closeIconAsset: closeIconAsset,
        closeBackgroundAsset: closeBackgroundAsset,
        notificationTitle: notificationTitle,
        notificationIconAsset: notificationIconAsset,
        flag: flag,
        enableDrag: enableDrag,
        notificationVisibility: notificationVisibility,
        snapEdge: snapEdge,
        snapMargin: snapMargin,
        persistPosition: persistPosition,
        entranceAnimation: entranceAnimation,
        theme: theme,
        sizePreset: sizePreset,
        debugMode: debugMode,
        assets: assets,
        notification: notification,
        snap: snap,
      ),
    );
  }

  /// {@macro floaty_chatheads_platform.close_chat_head}
  static Future<void> closeChatHead() => _platform.closeChatHead();

  /// {@macro floaty_chatheads_platform.is_active}
  static Future<bool> isActive() => _platform.isActive();

  /// {@macro floaty_chatheads_platform.add_chat_head}
  ///
  /// [id] uniquely identifies this bubble. [iconSource] provides the
  /// bubble's icon from any supported source (asset, network, bytes).
  /// The deprecated [iconAsset] is kept for backward compatibility.
  static Future<void> addChatHead({
    required String id,
    @Deprecated('Use iconSource instead') String? iconAsset,
    IconSource? iconSource,
  }) =>
      _platform.addChatHead(
        AddChatHeadConfig(
          id: id,
          iconAsset: iconAsset,
          iconSource: iconSource,
        ),
      );

  /// {@macro floaty_chatheads_platform.remove_chat_head}
  static Future<void> removeChatHead(String id) =>
      _platform.removeChatHead(id);

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) => _platform.updateBadge(count);

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  static Future<void> expandChatHead() => _platform.expandChatHead();

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  static Future<void> collapseChatHead() => _platform.collapseChatHead();

  /// {@template floaty_chatheads.share_data}
  /// Sends data from the main app to the overlay isolate.
  ///
  /// The data is serialized via `JSONMessageCodec` and forwarded
  /// through a `BasicMessageChannel`.
  /// {@endtemplate}
  static Future<void> shareData(Object? data) => FloatyChannel.send(data);

  /// {@template floaty_chatheads.dispose}
  /// Detaches the message handler.
  ///
  /// Safe to call multiple times. After calling, [onData] will
  /// re-attach the handler automatically on the next access.
  /// {@endtemplate}
  static void dispose() {
    FloatyChannel.dispose();
  }
}
