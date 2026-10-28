/// Canonical channel names used by floaty_chatheads.
///
/// These names form the contract between the Dart side, the Android Kotlin
/// service (`utils/Constants.kt`), and the iOS Swift plugin
/// (`FloatyChatheadsPlugin.swift`). Any change here must be mirrored in both
/// native files or main app and overlay communication will silently break.
abstract final class FloatyChannels {
  /// Shared `BasicMessageChannel` used for main app and overlay messaging.
  ///
  /// Carries raw user payloads as well as system-routed messages for
  /// state sync, action routing, and proxy invocations.
  static const String messenger = 'ni.devotion.floaty_head/messenger';

  /// Map key that marks a message on [messenger] as a system message.
  static const String envelope = '__floaty__';

  /// System prefix the main app sends to ask whether the overlay isolate
  /// is listening yet.
  static const String ping = '_floaty_ping';

  /// Reply the overlay isolate sends to [ping] once it is listening.
  static const String pong = '_floaty_pong';
}
