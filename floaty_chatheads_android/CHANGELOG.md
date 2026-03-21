# Changelog

## 1.0.6

### 🐛 Bug Fixes

- **Fixed `CompletableFuture` crash on Android 6.0 (API 23).**
  `CompletableFuture.supplyAsync` requires API 24+, but the module's
  `minSdkVersion` is 23. Replaced with `ExecutorService` +
  `Callable` (available since API 1) for parallel icon loading.
- **Fixed resource leak in `loadBitmapFromNetwork`.** `InputStream` and
  `HttpURLConnection` are now released via `use { }` and a `finally`
  block, ensuring cleanup even if `BitmapFactory.decodeStream` throws.

## 1.0.5

### 🐛 Bug Fixes

- **Fixed chathead close crash when GPS streaming is active.** Removing
  the `FlutterView` from its parent during the drag-to-close gesture
  while the overlay engine was still processing GPS data caused a 300ms
  window of orphaned rendering. The redundant `content.removeAllViews()`
  call was removed — `closeWindow(true)` already handles cleanup via
  `detachEngine()`.
- **Fixed foreground service not stopping after chathead close.** The
  `destroyEngine()` call threw an exception (self-destructing engine
  from Pigeon handler), preventing `stopSelf()` from being reached.
  Reordered service teardown so `stopForeground()` and `stopSelf()`
  execute before `destroyEngine()`, with the latter wrapped in a
  try/catch.
- **Fixed NPE in `hideChatHeads` delayed callback.** Replaced
  `FloatyContentJobService.instance!!` force-unwrap with safe call `?.`
  to handle cases where the service is already destroyed.

### ✨ Enhancements

- **Deferred connection signal on app restart.** `onAttachedToEngine`
  no longer sends `connected:true` to the overlay immediately when an
  existing service is detected. Instead it sets up the message relay
  via `onMainAppRelay()` and defers the connection signal until
  `isChatHeadActive()` is called from the Dart side — acting as an
  implicit "ready" signal that guarantees channel handlers are
  registered before the overlay flushes its action queue.
- **Native close notification to main app.** When the chathead is
  closed via drag-to-close or the overlay's close button, the native
  layer now sends a system envelope message to the main Dart isolate
  so `FloatyChatheads.onClosed` fires reliably.
- **Extracted magic delay constants.** Replaced inline delay numbers
  with named companion-object constants (`CLOSE_DELAY_MS`,
  `HIDE_DELAY_MS`, `EXPAND_CONTENT_DELAY_MS`).
- **Improved null safety in `onSpringUpdate`.** Replaced ~10
  `topChatHead!!` force-unwraps with a safe local binding.
- **DRY: consolidated `hideChatHeads()`.** Merged two near-identical
  branches into a single method with an `isClosed` parameter.
- **DRY: extracted `notifyOverlay()` helper.** Consolidated 5
  repeated Pigeon notification methods into a single inline function.
- **Added `NotificationConfig.description` support.** The foreground
  notification now shows a custom title and body text when
  `description` is provided.

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
