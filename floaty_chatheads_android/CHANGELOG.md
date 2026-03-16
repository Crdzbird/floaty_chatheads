# Changelog

## 1.0.2

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
