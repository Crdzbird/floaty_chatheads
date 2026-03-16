import 'package:floaty_chatheads_platform_interface/src/method_channel_floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/src/models/add_chat_head_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/chat_head_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/overlay_flag.dart';
import 'package:floaty_chatheads_platform_interface/src/models/overlay_position.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'src/models/add_chat_head_config.dart';
export 'src/models/chat_head_assets.dart';
export 'src/models/chat_head_config.dart';
export 'src/models/chat_head_theme.dart';
export 'src/models/content_size_preset.dart';
export 'src/models/entrance_animation.dart';
export 'src/models/icon_source.dart';
export 'src/models/notification_config.dart';
export 'src/models/notification_visibility.dart';
export 'src/models/overlay_flag.dart';
export 'src/models/overlay_position.dart';
export 'src/models/snap_config.dart';
export 'src/models/snap_edge.dart';

/// {@template floaty_chatheads_platform}
/// The interface that implementations of floaty_chatheads must implement.
///
/// Platform implementations should extend this class rather than implement it.
/// {@endtemplate}
abstract class FloatyChatheadsPlatform extends PlatformInterface {
  /// {@macro floaty_chatheads_platform}
  FloatyChatheadsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FloatyChatheadsPlatform _instance = MethodChannelFloatyChatheads();

  /// The default instance of [FloatyChatheadsPlatform] to use.
  static FloatyChatheadsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own class that
  /// extends [FloatyChatheadsPlatform] when they register themselves.
  static set instance(FloatyChatheadsPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// {@template floaty_chatheads_platform.check_permission}
  /// Checks whether overlay permission is granted.
  ///
  /// On Android, checks for `SYSTEM_ALERT_WINDOW`.
  /// On iOS, always returns `true` (no special permission needed).
  /// {@endtemplate}
  Future<bool> checkPermission() {
    throw UnimplementedError('checkPermission() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.request_permission}
  /// Opens the system overlay permission settings screen.
  ///
  /// Returns `true` if the user granted permission.
  /// On iOS, always returns `true`.
  /// {@endtemplate}
  Future<bool> requestPermission() {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.show_chat_head}
  /// Shows the chathead with the given [config].
  ///
  /// Creates a foreground service (Android) or a `UIWindow` overlay (iOS),
  /// launches a separate Flutter engine with the configured entry point,
  /// and renders the chathead bubble.
  /// {@endtemplate}
  Future<void> showChatHead(ChatHeadConfig config) {
    throw UnimplementedError('showChatHead() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.close_chat_head}
  /// Closes the chathead and stops the overlay service.
  /// {@endtemplate}
  Future<void> closeChatHead() {
    throw UnimplementedError('closeChatHead() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.is_active}
  /// Whether the chathead overlay is currently active.
  /// {@endtemplate}
  Future<bool> isActive() {
    throw UnimplementedError('isActive() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.add_chat_head}
  /// Adds a new chathead bubble to the existing group.
  /// {@endtemplate}
  Future<void> addChatHead(AddChatHeadConfig config) {
    throw UnimplementedError('addChatHead() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.remove_chat_head}
  /// Removes a chathead bubble by its [id].
  ///
  /// If the removed bubble was the last one, the overlay service stops.
  /// {@endtemplate}
  Future<void> removeChatHead(String id) {
    throw UnimplementedError('removeChatHead() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.resize_content}
  /// Resizes the overlay content panel to [width] x [height] logical pixels.
  /// {@endtemplate}
  Future<void> resizeContent(int width, int height) {
    throw UnimplementedError('resizeContent() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.update_flag}
  /// Updates the window behavior flag.
  ///
  /// See [OverlayFlag] for available values.
  /// {@endtemplate}
  Future<void> updateFlag(OverlayFlag flag) {
    throw UnimplementedError('updateFlag() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.close_overlay}
  /// Closes the overlay from inside the overlay isolate.
  /// {@endtemplate}
  Future<void> closeOverlay() {
    throw UnimplementedError('closeOverlay() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.get_overlay_position}
  /// Gets the current overlay position as an [OverlayPosition].
  /// {@endtemplate}
  Future<OverlayPosition> getOverlayPosition() {
    throw UnimplementedError('getOverlayPosition() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.update_badge}
  /// Updates the badge count on the chathead bubble.
  ///
  /// Pass `0` to hide the badge.
  /// {@endtemplate}
  Future<void> updateBadge(int count) {
    throw UnimplementedError('updateBadge() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.expand_chat_head}
  /// Programmatically expands the chathead to show its content panel.
  ///
  /// Has no effect if the chathead is already expanded.
  /// {@endtemplate}
  Future<void> expandChatHead() {
    throw UnimplementedError('expandChatHead() has not been implemented.');
  }

  /// {@template floaty_chatheads_platform.collapse_chat_head}
  /// Programmatically collapses the chathead content panel.
  ///
  /// Has no effect if the chathead is already collapsed.
  /// {@endtemplate}
  Future<void> collapseChatHead() {
    throw UnimplementedError('collapseChatHead() has not been implemented.');
  }
}
