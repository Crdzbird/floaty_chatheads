# Changelog

## 1.0.4

### 🐛 Bug Fixes

- **Fixed overlay ↔ main app communication completely broken.** When
  `FlutterEngineGroup.createAndRunEngine()` creates the overlay engine,
  it auto-registers all plugins — including `FloatyChatheadsPlugin`.
  This second `onAttachedToEngine` call overwrote the companion-object
  `activeInstance` and `mainMessenger` with the overlay engine's
  instances, causing all messages from the overlay to loop back to the
  overlay instead of reaching the main Dart isolate. Added an
  `activeInstance != null` guard in `onAttachedToEngine` to skip setup
  on the overlay engine, and a matching `isMainEnginePlugin` guard in
  `onDetachedFromEngine` to prevent the overlay engine from tearing
  down the main engine's state.

### 📦 Metadata

- Shortened pubspec description to meet pub.dev 60–180 character guideline.
- Added `example/example.md` for the pub.dev example tab.

## 1.0.3

### ✨ Enhancements

- **Upgraded Pigeon to 26.2.3.** Regenerated all Dart and Kotlin Pigeon
  bindings. No API surface changes — the upgrade picks up codec and
  code-generation improvements from the latest Pigeon release.

## 1.0.2

### ✨ Enhancements

- **Debug logs are now optional and silent by default.** All native
  `Log.d/w/e` output is gated behind `Managment.debugMode`. Developers
  enable verbose logging by setting `debugMode: true` in `ChatHeadConfig`;
  production builds produce zero log noise. Three convenience helpers
  (`Managment.logD`, `logW`, `logE`) replace every raw `Log.*` call
  across `FloatyContentJobService`, `FlutterContentPanel`, and `ChatHeads`.

### 🐛 Bug Fixes

- **Fixed content panel rendering fullscreen on subsequent launches.**
  The root cause was a two-stage data loss: when the service had not
  started yet, `showChatHead()` only persisted the entry point to
  `SharedPreferences`, omitting content dimensions and all other config.
  When the service's `onCreate()` later called `restoreConfig()`, it
  overwrote the in-memory `Managment` values with `null`, causing
  `createWindow()` to skip `setContentSize()` and fall back to
  `MATCH_PARENT`. The fix saves the **full config** to SharedPreferences
  in the plugin's else branch and adds a defensive guard in `onCreate()`
  to skip `restoreConfig()` when `Managment` is already populated.
- Fixed content panel dimensions and touch interaction leaking between
  chathead sessions. The plugin now explicitly tears down stale windows
  and calls `createWindow()` directly with fresh `Managment` values
  instead of deferring to `onStartCommand()`.

## 1.0.1

- Documentation and metadata updates.


## 1.0.0

### 🎉 Initial Release

- Android implementation of `floaty_chatheads` using `SYSTEM_ALERT_WINDOW`.
- Pigeon-generated type-safe Dart ↔ Kotlin communication.
- Facebook Rebound spring physics for bubble drag and snap animations.
- Foreground service with configurable notification.
- Separate `FlutterEngine` for overlay content panels.
- Theming support: badge colors, bubble border, shadow, close tint.
- Overlay palette delivery to Flutter overlay isolate.
- Size preset resolution with half-screen and full-screen sentinels.
- Debug overlay view with bounds, spring HUD, FPS counter, and
  Pigeon message log.
- Full TalkBack accessibility: content descriptions, state announcements,
  focus management, and custom accessibility actions.
- Snap-to-edge with configurable margin and position persistence.
- Entrance animations: slide-in and fade-in variants.
- Badge counter updates from both main app and overlay.
- Programmatic expand / collapse.
