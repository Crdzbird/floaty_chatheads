# Changelog

## 1.0.2

### 🐛 Bug Fixes

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
