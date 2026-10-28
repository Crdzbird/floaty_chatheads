import 'dart:typed_data';

import 'package:floaty_chatheads/src/chatheads/add_chat_head_function.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_add_chat_head.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_closed_events.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_icon_animation.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_show_chat_head.dart';
import 'package:floaty_chatheads/src/chatheads/show_chat_head_function.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_chatheads}
/// Main app API for controlling the floating chathead without the
/// permission flow of `Floaty`. All members are static.
/// {@endtemplate}
final class FloatyChatheads {
  FloatyChatheads._();

  static FloatyChatheadsPlatform get _platform =>
      FloatyChatheadsPlatform.instance;

  /// Whether an animated icon render loop is currently running.
  static bool get isIconAnimating => FloatyIconAnimation.isRunning;

  /// Stops the icon animation, keeping the last frame; resume it with
  /// [startIconAnimation].
  static void stopIconAnimation() => FloatyIconAnimation.stop();

  /// Starts the icon animation configured via [showChatHead]. No-op when
  /// none was configured or it is already running.
  static void startIconAnimation() => FloatyIconAnimation.start();

  /// {@template floaty_chatheads.on_closed}
  /// Stream that emits the chathead ID when the overlay is closed by the
  /// native gesture (drag-to-close) or from the overlay itself.
  /// {@endtemplate}
  static Stream<String> get onClosed => FloatyClosedEvents.stream;

  /// Stream of messages sent from the overlay isolate.
  static Stream<Object?> get onData => FloatyChannel.rawMessages;

  /// {@macro floaty_chatheads_platform.check_permission}
  static Future<bool> checkPermission() => _platform.checkPermission();

  /// {@macro floaty_chatheads_platform.request_permission}
  static Future<bool> requestPermission() => _platform.requestPermission();

  /// {@macro floaty_chatheads_platform.show_chat_head}
  ///
  /// Pass `iconWidget` to render any widget as the bubble, or
  /// `iconBuilder` (receives a 0.0 to 1.0 value) with `animateIcon: true`
  /// for an animated icon. `closeIconWidget` and `closeBackgroundWidget`
  /// do the same for the close target. Priority: iconBuilder, iconWidget,
  /// assets, defaults.
  static const ShowChatHeadFunction showChatHead = FloatyShowChatHead.show;

  /// {@macro floaty_chatheads_platform.close_chat_head}
  static Future<void> closeChatHead() {
    FloatyIconAnimation.dispose();
    return _platform.closeChatHead();
  }

  /// {@macro floaty_chatheads_platform.is_active}
  static Future<bool> isActive() => _platform.isActive();

  /// {@macro floaty_chatheads_platform.add_chat_head}
  ///
  /// Pass `iconSource` or `iconWidget`, rendered at `iconSize`.
  static const AddChatHeadFunction addChatHead = FloatyAddChatHead.add;

  /// {@macro floaty_chatheads_platform.remove_chat_head}
  static Future<void> removeChatHead(String id) => _platform.removeChatHead(id);

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) => _platform.updateBadge(count);

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  static Future<void> expandChatHead() => _platform.expandChatHead();

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  static Future<void> collapseChatHead() => _platform.collapseChatHead();

  /// {@macro floaty_chatheads_platform.update_chat_head_icon}
  static Future<void> updateChatHeadIcon({
    required Uint8List rgbaBytes,
    required int width,
    required int height,
    String id = 'default',
  }) => _platform.updateChatHeadIcon(id, rgbaBytes, width, height);

  /// Sends data from the main app to the overlay isolate.
  static Future<void> shareData(Object? data) => FloatyChannel.send(data);

  /// Stops any icon animation and detaches the close handler. Safe to call
  /// multiple times.
  static void dispose() {
    FloatyIconAnimation.dispose();
    FloatyClosedEvents.reset();
  }
}
