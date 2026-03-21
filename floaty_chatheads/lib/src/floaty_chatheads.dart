import 'dart:async';

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
///   assets: ChatHeadAssets.defaults(),
/// );
/// ```
/// {@endtemplate}
final class FloatyChatheads {
  FloatyChatheads._(); // coverage:ignore-line

  static FloatyChatheadsPlatform get _platform =>
      FloatyChatheadsPlatform.instance;

  static const _closedPrefixKey = '_floaty_closed';
  static final StreamController<String> _closeController =
      StreamController<String>.broadcast();
  static bool _closedHandlerRegistered = false;

  static void _ensureClosedHandler() {
    if (!_closedHandlerRegistered) {
      FloatyChannel.registerHandler(_closedPrefixKey, (data) {
        final id = data['id'] as String? ?? 'default';
        _closeController.add(id);
      });
      _closedHandlerRegistered = true;
    }
  }

  /// {@template floaty_chatheads.on_closed}
  /// Stream that emits the chathead ID when the overlay is closed
  /// by the native gesture (drag-to-close) or from the overlay itself.
  ///
  /// Use this to update your UI state when the chathead is dismissed
  /// without the main app explicitly calling [closeChatHead].
  /// {@endtemplate}
  static Stream<String> get onClosed {
    _ensureClosedHandler();
    FloatyChannel.ensureListening();
    return _closeController.stream;
  }

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
  /// When [debugMode] is `true`, icon loading failures and other native-side
  /// issues are logged to the platform debug console (Logcat on Android,
  /// Xcode console on iOS).
  static Future<void> showChatHead({
    String entryPoint = 'overlayMain',
    int? contentWidth,
    int? contentHeight,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
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
        flag: flag,
        enableDrag: enableDrag,
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
  static Future<void> addChatHead({
    required String id,
    IconSource? iconSource,
  }) =>
      _platform.addChatHead(
        AddChatHeadConfig(
          id: id,
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
    FloatyChannel.unregisterHandler(_closedPrefixKey);
    _closedHandlerRegistered = false;
    FloatyChannel.dispose();
  }
}
