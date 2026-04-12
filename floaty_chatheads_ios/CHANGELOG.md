# Changelog

## 1.1.6

### ✨ Enhancements

- **Added `updateChatHeadIcon` bridge method.** No-op on iOS (the
  chathead is already a `FlutterViewController`) but provides API
  symmetry with the Android implementation so Dart-side code does not
  need platform checks.

### 📦 Dependencies

- Bumped `floaty_chatheads_platform_interface` to `^1.0.5`.

## 1.1.5

### ⚡ Performance

- **Migrated to Swift Concurrency (`@MainActor`).**
  Replaced `@unchecked Sendable` conformance and manual
  `DispatchQueue.main.async` dispatching with `@MainActor` isolation
  on the plugin class. All Pigeon API methods now have compile-time
  main-thread safety enforcement instead of runtime GCD checks.
- Marked `register(with:)` as `nonisolated` with
  `MainActor.assumeIsolated` for Flutter registrar compatibility.

### 🐛 Bug Fixes

- **Fixed chathead freeze during drag.** The `@MainActor` annotation
  caused `UIPanGestureRecognizer` callbacks to route through the
  MainActor executor instead of executing synchronously. The pan
  handler is now `nonisolated` with `MainActor.assumeIsolated` to
  guarantee zero-overhead synchronous dispatch.
- **Fixed message handler closures.** `setMessageHandler` closures
  for both main and overlay messengers now use
  `MainActor.assumeIsolated` to prevent async actor hops during
  message forwarding.

## 1.1.4

### ✨ Enhancements

- **Native close notification to main app.** When the overlay is
  destroyed (drag-to-close or programmatic close), the iOS layer now
  sends a system envelope message to the main Dart isolate so
  `FloatyChatheads.onClosed` fires reliably.

## 1.1.3

### 📦 Metadata

- Shortened pubspec description to meet pub.dev 60–180 character guideline.
- Added `example/example.md` for the pub.dev example tab.

## 1.1.2

### ✨ Enhancements

- **Upgraded Pigeon to 26.2.3.** Regenerated all Dart and Swift Pigeon
  bindings. No API surface changes — the upgrade picks up codec and
  code-generation improvements from the latest Pigeon release.

## 1.1.1

### 🐛 Bug Fixes

- Fixed content panel size leaking between chathead sessions. The
  `contentSize` is now reset to defaults (300x400) before applying the
  new config so previous session dimensions don't persist.

## 1.1.0

### 🚀 iOS Feature Parity

- **Entrance animations**: `none`, `pop`, `slideFromEdge`, `fade` with spring physics.
- **Snap-to-edge**: `both`, `left`, `right`, `none` with configurable margin.
- **Position persistence**: saves and restores chathead position via `UserDefaults`.
- **Badge counter**: red pill badge with count, themed colors, caps at "99+".
- **Theming**: bubble border color/width, shadow color, badge colors, overlay palette delivery.
- **Expand / Collapse**: programmatic expand/collapse with animated transitions.
- **Drag lifecycle events**: `onChatHeadDragStart` and `onChatHeadDragEnd` callbacks.
- **VoiceOver accessibility**: `accessibilityLabel`, `accessibilityValue` for badge,
  screen change notifications on expand/collapse.
- **Debug info**: `getDebugInfo()` returns overlay state, window frame, snap config.
- Updated Pigeon schema to match Android with all new enums, models, and API methods.
- Full size preset support via Dart-side resolution.

## 1.0.1

- Documentation and metadata updates.


## 1.0.0

### 🎉 Initial Release

- iOS implementation of `floaty_chatheads` using `UIWindow` PiP overlay.
- Window level set to `.alert + 1` — no special permissions required.
- Pigeon-generated type-safe Dart ↔ Swift communication.
- `UIPanGestureRecognizer` for bubble drag.
- Supports iOS 13+ with Swift 6.1.
- Permission stubs (always returns `true`).
- Content panel resize, overlay flag updates, and position queries.
- Multi-bubble add / remove by ID.
