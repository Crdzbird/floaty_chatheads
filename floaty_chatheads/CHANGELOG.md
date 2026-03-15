# Changelog

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
