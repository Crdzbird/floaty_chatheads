import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_launcher.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty}
/// The shortest path to a working chathead.
///
/// `Floaty` is a thin, opinionated facade over [FloatyLauncher] and
/// [FloatyChatheads]. It collapses the most common workflow
/// (check permission → request if needed → show with defaults) into a
/// single call:
///
/// ```dart
/// // Step 1 — top-level entry point (overlay isolate)
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(
///   const FloatySimplePanel(
///     title: 'Hello',
///     child: Text('I am a floating overlay.'),
///   ),
/// );
///
/// // Step 2 — anywhere in your app
/// ElevatedButton(
///   onPressed: () => Floaty.show(),
///   child: const Text('Show Chathead'),
/// );
/// ```
///
/// That's it — no asset bundling, no permission boilerplate, no
/// `ChatHeadConfig`. On Android the bubble uses a built-in default
/// icon; on iOS the overlay is rendered entirely by your Flutter
/// widget so no icon is required.
///
/// **Need more control?** Drop down one layer at a time:
///
/// - [FloatyLauncher.show] — same workflow but with the full
///   parameter surface (assets, theme, snap, entrance animation, …).
/// - [FloatyChatheads.showChatHead] — bypasses permission handling
///   entirely; you call [FloatyChatheads.requestPermission] yourself.
/// - For two-way messaging with state, use
///   [FloatyHostKit] / [FloatyOverlayKit].
/// {@endtemplate}
final class Floaty {
  Floaty._(); // coverage:ignore-line

  /// {@template floaty.show}
  /// Checks the overlay permission (Android), requests it if needed,
  /// then shows the chathead.
  ///
  /// Returns `true` if the chathead is now visible, `false` if the
  /// user denied permission.
  ///
  /// Optional parameters cover the most common tweaks; for the full
  /// configuration surface (assets, theme, drag flag, …) use
  /// [FloatyLauncher.show] directly.
  /// {@endtemplate}
  static Future<bool> show({
    String entryPoint = 'overlayMain',
    String? title,
    ContentSizePreset size = ContentSizePreset.card,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
  }) =>
      FloatyLauncher.show(
        entryPoint: entryPoint,
        sizePreset: size,
        entranceAnimation: entranceAnimation,
        notification: title != null
            ? NotificationConfig(title: title)
            : null,
      );

  /// {@template floaty.toggle}
  /// Shows the chathead if it is closed; closes it if it is open.
  ///
  /// Returns `true` when the chathead ends up visible, `false` when
  /// closed (or when permission was denied).
  /// {@endtemplate}
  static Future<bool> toggle({
    String entryPoint = 'overlayMain',
    String? title,
    ContentSizePreset size = ContentSizePreset.card,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
  }) =>
      FloatyLauncher.toggle(
        entryPoint: entryPoint,
        sizePreset: size,
        entranceAnimation: entranceAnimation,
        notification: title != null
            ? NotificationConfig(title: title)
            : null,
      );

  /// {@template floaty.close}
  /// Closes the chathead. No-op if already closed.
  /// {@endtemplate}
  static Future<void> close() => FloatyChatheads.closeChatHead();

  /// {@template floaty.is_active}
  /// Whether the chathead is currently visible.
  /// {@endtemplate}
  static Future<bool> isActive() => FloatyChatheads.isActive();

  /// {@template floaty.send}
  /// Sends raw data to the overlay isolate.
  ///
  /// For typed bidirectional messaging with state and actions, use
  /// [FloatyHostKit] instead.
  /// {@endtemplate}
  static Future<void> send(Object? data) =>
      FloatyChatheads.shareData(data);

  /// {@template floaty.on_data}
  /// Stream of raw data received from the overlay.
  ///
  /// For typed messaging, see [FloatyHostKit] and [FloatyMessenger].
  /// {@endtemplate}
  static Stream<Object?> get onData => FloatyChatheads.onData;
}
