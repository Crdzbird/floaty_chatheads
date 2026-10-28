import 'dart:typed_data';

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:floaty_chatheads_platform_interface/src/method_channel_floaty_chatheads.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'floaty_chatheads_platform_controls.dart';

/// {@template floaty_chatheads_platform}
/// The interface that implementations of floaty_chatheads must implement.
///
/// Platform implementations should extend this class rather than implement it.
/// {@endtemplate}
abstract class FloatyChatheadsPlatform extends PlatformInterface
    with _FloatyChatheadsControls {
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

  static Never _unimplemented(String name) =>
      throw UnimplementedError('$name() has not been implemented.');

  /// {@template floaty_chatheads_platform.supports_native_icons}
  /// Whether the native bubble draws icons sent from Dart.
  ///
  /// `false` on iOS, where the bubble is part of the overlay's Flutter
  /// view: icon widgets are not rendered and animated icons do not run.
  /// {@endtemplate}
  bool get supportsNativeIcons => true;

  /// {@template floaty_chatheads_platform.check_permission}
  /// Checks whether overlay permission is granted.
  ///
  /// On Android, checks for `SYSTEM_ALERT_WINDOW`.
  /// On iOS, always returns `true` (no special permission needed).
  /// {@endtemplate}
  Future<bool> checkPermission() => _unimplemented('checkPermission');

  /// {@template floaty_chatheads_platform.request_permission}
  /// Opens the system overlay permission settings screen.
  ///
  /// Returns `true` if the user granted permission.
  /// On iOS, always returns `true`.
  /// {@endtemplate}
  Future<bool> requestPermission() => _unimplemented('requestPermission');

  /// {@template floaty_chatheads_platform.show_chat_head}
  /// Shows the chathead with the given [config].
  ///
  /// Creates a foreground service (Android) or a `UIWindow` overlay (iOS),
  /// launches a separate Flutter engine with the configured entry point,
  /// and renders the chathead bubble.
  /// {@endtemplate}
  Future<void> showChatHead(ChatHeadConfig config) =>
      _unimplemented('showChatHead');

  /// {@template floaty_chatheads_platform.close_chat_head}
  /// Closes the chathead and stops the overlay service.
  /// {@endtemplate}
  Future<void> closeChatHead() => _unimplemented('closeChatHead');

  /// {@template floaty_chatheads_platform.is_active}
  /// Whether the chathead overlay is currently active.
  /// {@endtemplate}
  Future<bool> isActive() => _unimplemented('isActive');

  /// {@template floaty_chatheads_platform.close_overlay}
  /// Closes the overlay from inside the overlay isolate.
  /// {@endtemplate}
  Future<void> closeOverlay() => _unimplemented('closeOverlay');
}
