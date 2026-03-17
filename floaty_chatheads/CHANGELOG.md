# Changelog

## 1.2.3

### 🐛 Bug Fixes

- **Fixed overlay → main app communication broken on Android.** The
  overlay `FlutterEngine` auto-registers all plugins, which overwrote
  the shared `activeInstance` in `FloatyChatheadsPlugin` with the
  overlay's instance. Messages sent from the overlay via `shareData()`
  looped back to the overlay instead of reaching the main app's
  `onData` stream. This affected all examples using raw
  `FloatyOverlay.shareData` / `FloatyChatheads.onData` communication
  (basic chathead, messenger, mini player, etc.). Bumped
  `floaty_chatheads_android` to `^1.0.4`.

## 1.2.2

### ✨ Enhancements

- **Upgraded Pigeon to 26.2.3.** Regenerated overlay Pigeon bindings
  across all platform packages. No API surface changes.
- **Updated Android demo GIF** in the media folder.

### 🐛 Bug Fixes

- **Fixed survival overlay counter adding +1 on every reconnection.**
  The overlay's manual re-dispatch logic fired even though the
  framework's automatic queue flush already delivered the queued
  actions, causing every increment to be applied twice. Removed the
  redundant re-dispatch — the queue flush is reliable on its own.
- **Fixed counter race condition on app restart.** Queued actions
  arriving via auto-flush before `SharedPreferences` restore could
  increment from zero instead of the persisted value. Increment
  actions are now buffered until the counter is restored.

## 1.2.1

### ✨ Enhancements

- **Debug logs are now optional and silent by default (Android).** All
  native logcat output from the plugin is gated behind `debugMode`. Set
  `debugMode: true` in `showChatHead()` to enable verbose logging during
  development; production builds produce zero log noise.

### 🐛 Bug Fixes

- **Fixed content panel rendering fullscreen on subsequent launches
  (Android).** When the foreground service had not started yet,
  `showChatHead()` only saved the entry point to SharedPreferences,
  omitting content dimensions. On service startup, `restoreConfig()`
  then overwrote the in-memory values with `null`, causing the panel to
  fall back to `MATCH_PARENT`. The plugin now persists the full config
  and the service guards against overwriting values that the plugin
  already set.
- Fixed content panel dimensions leaking between chathead sessions on
  Android. Switching from a larger overlay (e.g. 300x400) to a smaller
  one (e.g. 220x220) no longer inherits the previous session's size.
- Fixed missing touch interaction on the content panel after switching
  between chathead sessions. The plugin now explicitly recreates the
  overlay window with fresh dimensions instead of relying on
  `onStartCommand()`, which could skip recreation when a stale window
  from a `START_STICKY` restart was still present.
- Fixed iOS content size not resetting between sessions — dimensions
  now default to 300x400 before applying the new config.

## 1.2.0

### 🧩 Higher-Level Convenience Widgets

- Added `FloatyDataBuilder<T>` — a reactive builder for the **main app side**
  that subscribes to `FloatyChatheads.onData`, reduces incoming messages into
  typed state via a `(T current, Object? raw) → T` reducer, and rebuilds
  automatically. Eliminates manual `StreamSubscription`, `setState`, and
  `dispose` boilerplate.

- Added `FloatyOverlayBuilder<T>` — a zero-boilerplate builder for the
  **overlay side** that handles `FloatyOverlay.setUp()`, stream subscriptions,
  `mounted` guards, and `FloatyOverlay.dispose()` automatically. Supports
  `onData` reducer, optional `onTapped` reducer, and `onInit` callback.
  Turns overlay widgets into `StatelessWidget` declarations.

- Added `FloatyOverlayApp.runScoped()` — a variant of `run()` that wraps the
  child in `FloatyScope`, so `FloatyScope.of(context)` works everywhere
  inside the overlay without manual wiring.

- Added `builder` parameter to `FloatyControllerWidget` — accepts a
  `Widget Function(BuildContext, FloatyController)` callback with reactive
  re-rendering via `ListenableBuilder`. The `child` parameter is now optional
  when `builder` is provided.

### 📦 Grouped Configuration Objects

- Added `ChatHeadAssets` — groups chathead icon, close icon, and close
  background into a single object. Old flat parameters are deprecated.
- Added `NotificationConfig` — groups notification title, icon, and
  visibility into a single object. Old flat parameters are deprecated.
- Added `SnapConfig` — groups snap edge, margin, and position persistence
  into a single object. Old flat parameters are deprecated.
- Added `IconSource` — polymorphic icon source with `IconSource.asset()`,
  `IconSource.network()`, and `IconSource.bytes()` constructors for
  flexible icon loading from assets, URLs, or raw byte data.

### ✨ Simplified Examples

- Simplified all **14 overlay entry points** from verbose 6-line blocks to
  single-line `FloatyOverlayApp.run()` calls (84 → 14 lines total).
- Rewrote `NotificationCounterOverlay` using `FloatyOverlayBuilder<int>` —
  now a `StatelessWidget` with zero lifecycle code.
- Rewrote `QuickActionOverlay` using `FloatyOverlayBuilder<bool>` —
  now a `StatelessWidget` with tap-to-toggle expand/collapse.
- Rewrote `QuickActionExample` using `FloatyDataBuilder<List<LogEntry>>` —
  incoming actions accumulate into a log via reducer, no manual subscription.

### 🧪 Tests

- Added 10 new tests for `FloatyDataBuilder` (5) and `FloatyOverlayBuilder`
  (5), bringing the total to **233 tests** across all packages.

## 1.1.0

### 🚀 iOS Feature Parity

- iOS now supports entrance animations, snap-to-edge, position persistence,
  badge counter, theming, expand/collapse, drag events, and VoiceOver
  accessibility.
- Removed "Android only" notes from platform interface docs.
- Bumped `floaty_chatheads_ios` dependency to `^1.1.0`.

### 🔗 Shared State Channel

- Added `FloatyStateChannel<T>` — a generic, type-safe channel for
  synchronizing arbitrary state between the main app and the overlay.
- Supports partial updates via `update()` and full replacements via `set()`.
- Provides a reactive `stream` of state changes and synchronous `state`
  access.
- Works with any serializable Dart model, not limited to a specific domain.

### 🛰️ Bidirectional Action Routing

- Added `FloatyActionRouter` — a typed, extensible action bus for
  dispatching structured commands between app and overlay.
- Register strongly-typed handlers with `on<A>()` and send actions with
  `send()`.
- Actions implement `FloatyAction` with `type` and `toJson()` for
  automatic serialization over the platform channel.

### 🪞 Overlay Proxy

- Added `FloatyProxy` — lets the overlay call app-side services (e.g.
  APIs, databases, repositories) without direct dependencies.
- `FloatyProxyHost` registers named service handlers in the main app.
- `FloatyProxyClient` invokes them from the overlay and receives
  `Future`-based responses.
- Enables clean separation of concerns between the overlay UI and
  app-side business logic.

### 🛡️ Overlay Survival After App Death (Android)

- The Android `FloatyContentJobService` now owns the Flutter engine
  lifecycle. The overlay survives when the main app is killed and
  automatically restores from persisted config on service restart.
- Added `FloatyConnectionState` — overlay-side utility that tracks
  whether the main app is connected, with a reactive stream and
  synchronous getter.
- `FloatyActionRouter` now queues dispatched actions while the main
  app is disconnected and flushes them in order on reconnection.
  Configurable `maxQueueSize` and `QueueOverflowStrategy`.
- `FloatyProxyClient` fails fast with `FloatyProxyDisconnectedException`
  when the main app is unavailable, with an optional `fallback`
  parameter to provide default values instead of throwing.
- `FloatyScopeData` exposes `isMainAppConnected` for reactive overlay
  UI updates.
- The plugin automatically reconnects to an existing overlay when the
  main app restarts (hot-restart or cold launch).

## 1.0.1

- Added Android and iOS demo GIFs to README.
- Fixed foreground notification on service reuse.
- Documentation and metadata updates.

## 1.0.0

### 🎉 Initial Release — Complete Rewrite

A ground-up rewrite of the floating chathead plugin, inspired by
[flutter_overlay_window](https://pub.dev/packages/flutter_overlay_window).

#### Platform Support

- **Android** — `SYSTEM_ALERT_WINDOW` overlay with foreground service,
  Facebook Rebound spring physics, and full `FlutterEngine` content panels.
- **iOS** — `UIWindow`-based PiP overlay at `.alert + 1` window level.
  No special permissions required. Supports iOS 13+.

#### Core Features

- Floating chathead bubbles rendered as system-level overlays.
- Expand / collapse Flutter widget content panels.
- Bidirectional data messaging between the main app and overlay isolate
  via `BasicMessageChannel`.
- Drag-and-drop with spring-animated snap-to-edge.
- Close target with magnetic snap and animated reveal.
- Badge counter on chathead bubbles.
- Multi-bubble support — add / remove individual chatheads by ID.

#### Theming API

- `ChatHeadTheme` model with badge colors, bubble border, shadow color,
  close tint, and overlay color palette.
- Automatic palette delivery to overlay isolate on engine start.
- `FloatyOverlay.palette` and `onPaletteChanged` stream for overlay-side
  consumption.

#### Size Presets

- `ContentSizePreset` enum: `compact`, `card`, `halfScreen`, `fullScreen`.
- Preset dimensions resolved before passing to the native layer.

#### Debug Inspector

- `debugMode` flag on `ChatHeadConfig`.
- `DebugOverlayView` (Android) with bounds rectangles, position labels,
  spring velocity HUD, and FPS counter.
- Pigeon message log (circular buffer, 50 entries).
- `FloatyOverlay.getDebugInfo()` for Dart-side debug panels.

#### Accessibility (Android)

- Full TalkBack support with content descriptions, state announcements,
  and accessibility actions on all interactive views.
- Focus management: content panel receives focus on expand, bubble
  receives focus on collapse.
- `ACTION_CLICK` ("Expand / Collapse chat") and `ACTION_DISMISS`
  ("Close chat bubble") custom actions.
- `AccessibilityLiveRegion.POLITE` on close target for automatic
  announcements.

#### Snap & Animation

- `SnapEdge` enum: `left`, `right`, `nearest`, `none`.
- Configurable snap margin in dp.
- `persistPosition` — remembers last bubble position across sessions.
- `EntranceAnimation` enum: `none`, `slideInFromLeft`, `slideInFromRight`,
  `fadeIn`.

#### Developer Experience

- Federated plugin architecture (main → platform_interface → android / ios).
- Pigeon-generated type-safe Dart ↔ Kotlin / Swift communication.
- VGV-style `{@template}` / `{@macro}` documentation across all packages.
- `FloatyPermissionGate` widget for declarative permission handling.
- 12 runnable example screens in the gallery app.

#### Architecture

- `floaty_chatheads` — app-facing API
- `floaty_chatheads_platform_interface` — abstract contract + models
- `floaty_chatheads_android` — Kotlin + Pigeon implementation
- `floaty_chatheads_ios` — Swift + Pigeon implementation
