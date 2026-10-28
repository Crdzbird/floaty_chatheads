import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty/floaty_show_command.dart';
import 'package:floaty_chatheads/src/floaty/floaty_show_function.dart';
import 'package:floaty_chatheads/src/floaty/floaty_toggle_command.dart';

/// {@template floaty}
/// The one-stop API for showing and talking to a chathead.
///
/// `Floaty` handles the overlay permission (check, request, await the
/// user's answer) and then shows the chathead with every option the
/// plugin supports:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(
///   const FloatySimplePanel(title: 'Hello', child: Text('Hi there.')),
/// );
///
/// ElevatedButton(onPressed: Floaty.show, child: const Text('Show'));
/// ```
///
/// No asset bundling, no manifest edits, no `ChatHeadConfig`. Use
/// [FloatyChatheads] only to skip the permission flow. For typed two-way
/// messaging see [FloatyHostKit] and [FloatyOverlayKit]; for raw data,
/// [send] and [onData].
/// {@endtemplate}
final class Floaty {
  Floaty._();

  /// {@template floaty.ensure_permission}
  /// Returns `true` when the overlay permission is granted, requesting
  /// it from the user first if needed. Always `true` on iOS.
  /// {@endtemplate}
  static Future<bool> ensurePermission() =>
      FloatyShowCommand.ensurePermission();

  /// {@template floaty.show}
  /// Checks the overlay permission (Android), requests it if needed, then
  /// shows the chathead. Returns `false` if the user denied permission.
  ///
  /// `entryPointLibrary` lets the entry point live outside `main.dart`.
  /// `size` picks a named panel size; `contentWidth` and `contentHeight`
  /// set exact dimensions instead. `title` is shorthand for
  /// `notification: NotificationConfig(title: ...)` and is ignored when
  /// `notification` is given. Icon priority: `iconBuilder`, `iconWidget`,
  /// `assets`, built-in defaults (see [FloatyChatheads.showChatHead]).
  /// {@endtemplate}
  static const FloatyShowFunction show = FloatyShowCommand.show;

  /// {@template floaty.toggle}
  /// Shows the chathead if it is closed; closes it if it is open. Returns
  /// `true` when it ends up visible. Takes the same options as [show].
  /// {@endtemplate}
  static const FloatyShowFunction toggle = FloatyToggleCommand.toggle;

  /// Closes the chathead. No-op if already closed.
  static Future<void> close() => FloatyChatheads.closeChatHead();

  /// Whether the chathead is currently visible.
  static Future<bool> isActive() => FloatyChatheads.isActive();

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  static Future<void> expand() => FloatyChatheads.expandChatHead();

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  static Future<void> collapse() => FloatyChatheads.collapseChatHead();

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) =>
      FloatyChatheads.updateBadge(count);

  /// Sends raw data to the overlay isolate. For typed messaging use
  /// [FloatyHostKit].
  static Future<void> send(Object? data) => FloatyChatheads.shareData(data);

  /// Stream of raw data received from the overlay.
  static Stream<Object?> get onData => FloatyChatheads.onData;

  /// {@macro floaty_chatheads.on_closed}
  static Stream<String> get onClosed => FloatyChatheads.onClosed;
}
