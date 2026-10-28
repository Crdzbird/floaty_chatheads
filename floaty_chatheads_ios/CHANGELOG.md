# Changelog

## 3.0.0

> **Breaking release.** Minimum Flutter 3.44 / Dart 3.12, iOS 15, Android
> API 24. Built-in Kotlin end to end. See the migration notes at the end.

- The overlay engine registers the host app's plugins
  (`GeneratedPluginRegistrant`), so other plugins work in the overlay.
- `entryPointLibrary` support via `run(withEntrypoint:libraryURI:)`.
- `showChatHead` completes once the overlay isolate is listening and
  throws `FloatyOverlayNotReadyException` (after closing the overlay) when
  it never starts.
- The main-to-overlay and overlay-to-main relays always reply, so sends
  no longer hang when the other side is gone.
- Showing again reuses the overlay engine when the entry point is
  unchanged; re-showing no longer fires a false close event.
- `supportsNativeIcons` is `false`: icon widgets are not rendered and
  animated icon frames are never sent to native code.
- `showChatHead` reports an `overlay_engine` error when the entry point
  cannot be started instead of succeeding silently.
- Deployment target 15.0; `Package.swift` declares the `FlutterFramework`
  dependency. Pigeon 29 with completion-style signatures.
- `FloatyChatheadsIOS` is now `final`.
- Minimum Flutter 3.44 / Dart 3.12.

## 2.1.0

### New: `PanelAnchor`

- **feat**: new `PanelAnchor` enum (`below` / `above` / `auto`) on
  `ChatHeadConfig.panelAnchor` controls where the expanded content panel
  opens relative to the bubble. The panel is always clamped to the screen
  bounds; `auto` picks below when there is room, otherwise above.

### Behavior change (non-breaking API)

- The content panel now opens **below the bubble by default**. Previously
  the panel rendered from the top of the screen with the bubble row
  overlapping its top edge (Android) or grew down-right from the bubble's
  corner (iOS). Full-screen panels are unaffected (clamping keeps them at
  the top). Overlays that reserved top padding for the bubble row on
  card-sized panels should remove it.
- **fix**: collapsing now returns the bubble to its pre-expand position
  (previously the bubble stayed at the panel's top-left corner). Dragging
  the expanded panel keeps the new position on collapse.

- **fix**: calling `FloatyOverlay.getOverlayPosition()` from the overlay
  isolate crashed with a decode error because the overlay isolate's Pigeon codec
  assigns different type tags than the platform contract serving the same
  channels. Shared overlay channels now use only standard-codec payloads
  (`getOverlayPosition` returns a map, `updateFlag` takes the enum index).

### Chores

- Podspec version synced with the package (was stale at 0.0.1) and
  metadata placeholders replaced.
- Added `PrivacyInfo.xcprivacy` (UserDefaults declared-reason API) to the
  SwiftPM target and CocoaPods resource bundle.
- Renamed `FloatyCheaheadsPlugin.swift` to `FloatyChatheadsPlugin.swift`.
- Pigeon regenerated with 26.3.x; animation and position-reporting
  helpers deduplicated.

## 2.0.0

> **Released as part of the floaty_chatheads 2.0 line.** See the main
> package CHANGELOG for the full migration guide.

### Toolchain (BREAKING)

- iOS deployment target raised to **14.0** (was 13.0) in both
  `Package.swift` and the CocoaPods podspec.
- Dart SDK floor `^3.0.0`, Flutter floor `>=3.10.0`. This matches the
  rest of the federated set and was picked as the bare minimum the Dart
  code requires.
- Pigeon constraint normalized to `^26.3.3`.
- Depends on `floaty_chatheads_platform_interface: ^2.0.0`.

### Documented platform behavior

- Added class-level and method-level documentation to
  `FloatyChatheadsIOS` explaining which `ChatHeadConfig` fields are
  intentionally not forwarded to the Swift side
  (`ChatHeadAssets`, `NotificationConfig.description`,
  `AddChatHeadConfig.iconSource`) and why. The iOS chathead renders as
  a Flutter view, so app authors render their own icons inside the
  overlay entry point.

### Internals

- `showChatHead` now delegates default-value resolution to
  `ChatHeadConfigResolver` in `floaty_chatheads_platform_interface`,
  removing ~30 lines of duplication with the Android Dart shim.

## 1.1.6

### Enhancements

- **Added `updateChatHeadIcon` bridge method.** No-op on iOS (the
  chathead is already a `FlutterViewController`) but provides API
  symmetry with the Android implementation so Dart-side code does not
  need platform checks.

### Dependencies

- Bumped `floaty_chatheads_platform_interface` to `^1.0.5`.

## 1.1.5

### Performance

- **Migrated to Swift Concurrency (`@MainActor`).**
  Replaced `@unchecked Sendable` conformance and manual
  `DispatchQueue.main.async` dispatching with `@MainActor` isolation
  on the plugin class. All Pigeon API methods now have compile-time
  main-thread safety enforcement instead of runtime GCD checks.
- Marked `register(with:)` as `nonisolated` with
  `MainActor.assumeIsolated` for Flutter registrar compatibility.

### Bug Fixes

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

### Enhancements

- **Native close notification to main app.** When the overlay is
  destroyed (drag-to-close or programmatic close), the iOS layer now
  sends a system envelope message to the main Dart isolate so
  `FloatyChatheads.onClosed` fires reliably.

## 1.1.3

### Metadata

- Shortened pubspec description to meet pub.dev 60 to 180 character guideline.
- Added `example/example.md` for the pub.dev example tab.

## 1.1.2

### Enhancements

- **Upgraded Pigeon to 26.2.3.** Regenerated all Dart and Swift Pigeon
  bindings. No API surface changes; the upgrade picks up codec and
  code-generation improvements from the latest Pigeon release.

## 1.1.1

### Bug Fixes

- Fixed content panel size leaking between chathead sessions. The
  `contentSize` is now reset to defaults (300x400) before applying the
  new config so previous session dimensions don't persist.

## 1.1.0

### iOS Feature Parity

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

### Initial Release

- iOS implementation of `floaty_chatheads` using `UIWindow` PiP overlay.
- Window level set to `.alert + 1`; no special permissions required.
- Pigeon-generated type-safe communication between Dart and Swift.
- `UIPanGestureRecognizer` for bubble drag.
- Supports iOS 13+ with Swift 6.1.
- Permission stubs (always returns `true`).
- Content panel resize, overlay flag updates, and position queries.
- Multi-bubble add / remove by ID.
