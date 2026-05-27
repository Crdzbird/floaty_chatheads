/// Canonical channel names used by floaty_chatheads.
///
/// These names form the contract between the Dart side, the Android Kotlin
/// service (`utils/Constants.kt`), and the iOS Swift plugin
/// (`FloatyCheaheadsPlugin.swift`). Any change here must be mirrored in both
/// native files or main ↔ overlay communication will silently break.
abstract final class FloatyChannels {
  /// Shared `BasicMessageChannel` used for main app ↔ overlay messaging.
  ///
  /// Carries raw user payloads as well as system-routed messages for
  /// state sync, action routing, and proxy invocations.
  static const String messenger = 'ni.devotion.floaty_head/messenger';
}
