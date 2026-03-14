# Floaty Chatheads

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![coverage: 100%][coverage_badge]][coverage_link]
[![tests: 132 passed][tests_badge]][tests_link]

## Installation

Add `floaty_chatheads` to your `pubspec.yaml`:

```yaml
dependencies:
  floaty_chatheads: ^1.0.0
```

Then run:

```bash
flutter pub get
```

**Requirements:**
- Dart SDK `^3.4.0`
- Flutter `>=3.22.0`
- Android 6.0+ (API 23) / iOS 13.0+

---

A Flutter federated plugin for floating chathead bubbles on **Android** and **iOS**.
On Android, chatheads live outside your app as system overlays powered by `SYSTEM_ALERT_WINDOW`.
On iOS, chatheads use an app-level `UIWindow` overlay at the `.alert + 1` window level.
Both platforms can host **any Flutter widget** as an expandable content panel -- think
Facebook Messenger-style bubbles, mini players, quick-action FABs, or full-screen dashboards.

> **Successor to [`floaty_chathead`](https://pub.dev/packages/floaty_chathead).**
> This is a complete rewrite of the original plugin with a federated architecture,
> Pigeon-generated type-safe platform channels, iOS support, theming, accessibility,
> debug tooling, and many more features. If you are migrating from `floaty_chathead`,
> see the [Migration](#migration-from-floaty_chathead) section below.

---

## Platform Comparison

The plugin exposes a **single Dart API** for both platforms, but the underlying
implementations differ due to OS-level constraints:

| Capability | Android | iOS |
|---|---|---|
| **Overlay scope** | System-wide (above all apps) | App-level (`UIWindow` PiP) |
| **Permissions** | `SYSTEM_ALERT_WINDOW` + foreground service | None required |
| **Bubble rendering** | Native `View` with bitmap icon | Flutter widget in `UIWindow` |
| **Edge snapping** | Spring-based snap with configurable margin | Bounds-clamped drag with animation |
| **Entrance animations** | Pop, slide, fade | Not yet implemented |
| **Badge counter** | Native drawn badge on bubble | Not yet implemented |
| **Expand / Collapse** | Native toggle with accessibility | Not yet implemented |
| **Theming** | Badge, border, shadow, close tint, palette | Not yet implemented |
| **Size presets** | Full support (compact, card, half, full) | Width/height respected |
| **Debug inspector** | FPS, spring HUD, bounds, message log | Not yet implemented |
| **TalkBack / VoiceOver** | Full TalkBack support | Not yet implemented |
| **Dragging** | Custom touch handler + spring physics | `UIPanGestureRecognizer` |
| **Position persistence** | Supported | Not yet implemented |
| **Foreground service** | Persists across app switches | N/A (app-level window) |
| **Separate Flutter engine** | Yes | Yes |
| **Bidirectional messaging** | Yes | Yes |
| **Click-through flag** | Yes | Yes (`isUserInteractionEnabled`) |
| **Resize from overlay** | Yes | Yes |
| **Close from overlay** | Yes | Yes |
| **Multi-bubble** | Messenger-style row | Via Flutter API callback |
| **Min platform version** | Android 6.0+ (API 23) | iOS 13.0+ |

> **Note:** On iOS, `checkPermission()` and `requestPermission()` always return `true`
> since no special permission is needed. Android-only parameters (notification title,
> snap edge, entrance animation, theme, debug mode, etc.) are accepted by the API
> but silently ignored on iOS.

---

## Features

| Category | Highlights |
|---|---|
| **Chathead Bubbles** | Draggable bubble with spring-based edge snapping (Android), entrance animations (pop, slide, fade), and multi-bubble support (Messenger-style row) |
| **Content Panel** | Any Flutter widget rendered in a separate engine isolate (`FlutterTextureView` on Android, `FlutterViewController` on iOS) |
| **Bidirectional Messaging** | `shareData` / `onData` streams for real-time main-app <-> overlay communication on both platforms |
| **Badge Counter** | Numeric badge on the bubble, updated from either side (Android) |
| **Theming API** | Badge colors, bubble border ring, shadow color, close-target tint, and a full overlay color palette forwarded to the overlay isolate (Android) |
| **Size Presets** | Named presets (`compact`, `card`, `halfScreen`, `fullScreen`) instead of raw pixel values |
| **Debug Inspector** | Native overlay showing FPS counter, spring velocity HUD, view bounds, and Pigeon message log (Android) |
| **TalkBack Accessibility** | Content descriptions, live-region state announcements, accessibility actions (click, dismiss), and focus management (Android) |
| **Lifecycle Events** | Streams for `onTapped`, `onClosed`, `onExpanded`, `onCollapsed`, `onDragStart`, `onDragEnd` |
| **Permission Gate** | `FloatyPermissionGate` widget that polls for `SYSTEM_ALERT_WINDOW` and shows a fallback until granted (Android; always passes on iOS) |
| **Programmatic Control** | `expandChatHead()`, `collapseChatHead()`, `addChatHead()`, `removeChatHead()`, dynamic `resizeContent()`, flag updates |
| **Foreground Service** | Runs as a foreground service so the overlay persists across app switches (Android) |

---

## Getting Started

### 1. Add the dependency

```yaml
dependencies:
  floaty_chatheads: ^1.0.0
```

### 2. Android setup

Add the required permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### 3. iOS setup

No special permissions or `Info.plist` entries are needed.
The overlay uses a `UIWindow` at `windowLevel = .alert + 1` within the app's process.

**Requirements:**
- iOS 13.0+
- Swift 6.1+

### 4. Declare assets

```yaml
flutter:
  assets:
    - assets/chatheadIcon.png
    - assets/close.png
    - assets/closeBg.png
    - assets/notificationIcon.png
```

> On iOS the icon assets are optional since the overlay is rendered entirely by
> your Flutter widget. On Android they are used for the native bubble bitmap and
> close-target drawable.

### 5. Create an overlay entry point

Every overlay runs in its **own Flutter engine**, so the entry-point function must be
top-level and annotated with `@pragma('vm:entry-point')`:

```dart
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyOverlayWidget(),
  ));
}
```

This works identically on both Android and iOS -- the plugin creates a dedicated
`FlutterEngine` (Android) or `FlutterEngine` + `FlutterViewController` (iOS) and
runs the named entry point inside it.

### 6. Show the chathead

```dart
import 'package:floaty_chatheads/floaty_chatheads.dart';

// Check / request permission first (no-op on iOS).
final granted = await FloatyChatheads.checkPermission();
if (!granted) await FloatyChatheads.requestPermission();

await FloatyChatheads.showChatHead(
  entryPoint: 'overlayMain',
  chatheadIconAsset: 'assets/chatheadIcon.png',
  closeIconAsset: 'assets/close.png',
  closeBackgroundAsset: 'assets/closeBg.png',
  notificationTitle: 'My Chathead',
);
```

---

## Convenience Helpers

The plugin ships convenience helpers that dramatically reduce boilerplate.

### `FloatyOverlayApp` -- one-liner overlay bootstrap

Replaces 5 lines of entry-point boilerplate with one call:

```dart
@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(const MyOverlayWidget());
```

Handles `ensureInitialized()`, `FloatyOverlay.setUp()`, and wraps your
widget in a `MaterialApp`. Accepts optional `theme` and `navigatorObservers`.

### `FloatyScope` -- auto-wired overlay context

An `InheritedWidget` that subscribes to **all** overlay streams and rebuilds
when any event fires. No manual stream wiring needed:

```dart
@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(
  const FloatyScope(child: MyOverlay()),
);

// Inside MyOverlay:
final scope = FloatyScope.of(context);
Text('Last message: ${scope.lastMessage}');
Text('Palette primary: ${scope.palette?.primary}');
```

Exposes: `lastMessage`, `messages`, `lastTappedId`, `lastClosedId`,
`lastExpandedId`, `lastCollapsedId`, `lastDragStart`, `lastDragEnd`,
and `palette`.

### `FloatyLauncher` -- one-call launch with auto permissions

Combines permission check + request + show into a single `Future<bool>`:

```dart
final shown = await FloatyLauncher.show(
  entryPoint: 'overlayMain',
  chatheadIcon: 'assets/icon.png',
  sizePreset: ContentSizePreset.card,
);
```

Also provides `FloatyLauncher.toggle()` to show/close with one call.

### `FloatyController` -- lifecycle-aware declarative control

A `ChangeNotifier`-based controller that manages the chathead lifecycle.
Automatically handles show/close tied to widget lifecycle:

```dart
FloatyControllerWidget(
  entryPoint: 'overlayMain',
  chatheadIcon: 'assets/icon.png',
  sizePreset: ContentSizePreset.card,
  onData: (data) => print('Got: $data'),
  child: MyPageContent(),
)
```

Or use the controller directly for fine-grained control:

```dart
final controller = FloatyController(
  entryPoint: 'overlayMain',
  chatheadIcon: 'assets/icon.png',
  onError: (e, st) => debugPrint('Error: $e'),
);
await controller.show();
await controller.toggle();
await controller.sendData({'action': 'refresh'});
```

### `FloatyMessenger<T>` -- type-safe messaging

Eliminates raw `Object?` casting with a serializer/deserializer pair:

```dart
// Main app side:
final messenger = FloatyMessenger<ChatMessage>(
  serialize: (msg) => msg.toJson(),
  deserialize: ChatMessage.fromJson,
);
messenger.send(ChatMessage(text: 'Hello!'));
messenger.messages.listen((ChatMessage msg) => print(msg.text));

// Overlay side:
final messenger = FloatyMessenger<ChatMessage>.overlay(
  serialize: (msg) => msg.toJson(),
  deserialize: ChatMessage.fromJson,
);
```

---

## Pre-built Overlay Widgets

Drop-in widgets for common overlay use cases. No custom UI needed.

### `FloatyMiniPlayer`

A media player overlay with play/pause, next/previous, progress bar,
and album art support:

```dart
@pragma('vm:entry-point')
void playerOverlay() => FloatyOverlayApp.run(
  FloatyMiniPlayer(
    title: 'Now Playing',
    subtitle: 'Artist Name',
    isPlaying: true,
    progress: 0.4,
    onPlayPause: () => FloatyOverlay.shareData({'action': 'toggle'}),
    onClose: FloatyOverlay.closeOverlay,
  ),
);
```

### `FloatyNotificationCard`

A toast/notification-style card with icon, title, body, and action buttons:

```dart
@pragma('vm:entry-point')
void notifOverlay() => FloatyOverlayApp.run(
  FloatyNotificationCard(
    title: 'New Message',
    body: 'You have 3 unread messages',
    icon: Icons.message,
    actions: [
      FloatyNotificationAction(label: 'View', onPressed: () {}),
      FloatyNotificationAction(label: 'Dismiss', onPressed: FloatyOverlay.closeOverlay),
    ],
  ),
);
```

---

## Test Suite & Coverage

The plugin ships with **147 unit and widget tests** across all 4 packages:

| Package | Tests | Status |
|---|---|---|
| `floaty_chatheads` | 132 | ✅ All passing |
| `floaty_chatheads_platform_interface` | 14 | ✅ All passing |
| `floaty_chatheads_android` | 1 | ✅ All passing |
| **Total** | **147** | ✅ |

### Coverage (handwritten code, excluding generated Pigeon files)

| File | Coverage |
|---|---|
| `floaty_chatheads.dart` | 100% |
| `floaty_controller.dart` | 100% |
| `floaty_launcher.dart` | 100% |
| `floaty_messenger.dart` | 100% |
| `floaty_overlay.dart` | 100% |
| `floaty_overlay_app.dart` | 100% |
| `floaty_permission_gate.dart` | 100% |
| `floaty_scope.dart` | 100% |
| `floaty_mini_player.dart` | 100% |
| `floaty_notification_card.dart` | 100% |
| `testing.dart` | 100% |
| **Overall** | **100%** |

> Platform-only code (Pigeon host API calls, `runApp()`, private constructors)
> is excluded via `coverage:ignore` directives — standard practice for Flutter
> federated plugins where those paths require a live platform host.

Run tests locally:

```bash
# Main package
cd floaty_chatheads && flutter test

# With coverage
flutter test --coverage

# Platform interface
cd floaty_chatheads_platform_interface && flutter test
```

---

## Testing Utilities

Import the testing utilities for unit testing overlay-dependent code:

```dart
import 'package:floaty_chatheads/testing.dart';
```

### `FakeFloatyPlatform`

Drop-in replacement for the platform instance. Tracks all method calls:

```dart
final fake = FakeFloatyPlatform();
FloatyChatheadsPlatform.instance = fake;

await FloatyChatheads.showChatHead(entryPoint: 'test');
expect(fake.showChatHeadCalled, isTrue);
expect(fake.lastConfig?.entryPoint, equals('test'));

// Control permission behavior:
fake.permissionGranted = false;
expect(await FloatyChatheads.checkPermission(), isFalse);
```

### `FakeOverlayDataSource`

Simulates overlay events for testing overlay-side widgets:

```dart
final fake = FakeOverlayDataSource();
fake.emitData({'action': 'refresh'});
fake.emitTapped('default');
```

### Quickstart

See [`example/lib/quickstart.dart`](example/lib/quickstart.dart)
for a complete, minimal integration using all the helpers (~120 lines total).

---

## API Reference

### `FloatyChatheads` (main app side)

| Method | Description | Android | iOS |
|---|---|---|---|
| `checkPermission()` | Returns `true` if overlay permission is granted | Yes | Always `true` |
| `requestPermission()` | Opens system settings for overlay permission | Yes | Always `true` |
| `showChatHead({...})` | Launches the chathead with full configuration | Yes | Yes |
| `closeChatHead()` | Closes the chathead and stops the service | Yes | Yes |
| `isActive()` | Whether the overlay is currently visible | Yes | Yes |
| `addChatHead({id, iconAsset})` | Adds another bubble to the group | Yes | Yes |
| `removeChatHead(id)` | Removes a bubble by ID | Yes | Yes |
| `updateBadge(count)` | Sets the badge number (0 hides it) | Yes | -- |
| `expandChatHead()` | Programmatically expands the content panel | Yes | -- |
| `collapseChatHead()` | Programmatically collapses the content panel | Yes | -- |
| `shareData(data)` | Sends data to the overlay isolate | Yes | Yes |
| `onData` | Stream of messages from the overlay | Yes | Yes |
| `dispose()` | Tears down the message channel | Yes | Yes |

### `FloatyOverlay` (overlay isolate side)

| Method | Description | Android | iOS |
|---|---|---|---|
| `setUp()` | Initializes the overlay message handler (call once) | Yes | Yes |
| `onData` | Stream of messages from the main app | Yes | Yes |
| `onTapped` / `onClosed` / `onExpanded` / `onCollapsed` | Lifecycle event streams | Yes | Yes |
| `onDragStart` / `onDragEnd` | Drag event streams with position info | Yes | Yes |
| `onPaletteChanged` | Stream of palette updates from the host | Yes | -- |
| `palette` | Current `OverlayColorPalette` (nullable) | Yes | -- |
| `resizeContent(w, h)` | Resizes the content panel from inside the overlay | Yes | Yes |
| `updateFlag(flag)` | Changes the window flag (e.g. click-through) | Yes | Yes |
| `updateBadge(count)` | Updates the badge from the overlay side | Yes | -- |
| `closeOverlay()` | Closes the overlay from inside | Yes | Yes |
| `getOverlayPosition()` | Returns the current overlay position | Yes | Yes |
| `getDebugInfo()` | Returns debug telemetry (debug mode only) | Yes | -- |
| `shareData(data)` | Sends data to the main app | Yes | Yes |
| `dispose()` | Tears down handlers | Yes | Yes |

---

## Theming

Pass a `ChatHeadTheme` to `showChatHead()` to customise the native bubble appearance
and deliver a color palette to your overlay widget (Android only for native theming;
the palette stream is forwarded on both platforms):

```dart
await FloatyChatheads.showChatHead(
  // ...
  theme: ChatHeadTheme(
    badgeColor: Colors.deepPurple.toARGB32(),
    badgeTextColor: Colors.white.toARGB32(),
    bubbleBorderColor: Colors.deepPurpleAccent.toARGB32(),
    bubbleBorderWidth: 2,
    bubbleShadowColor: Colors.black54.toARGB32(),
    closeTintColor: Colors.redAccent.toARGB32(),
    overlayPalette: {
      'primary': Colors.deepPurple.toARGB32(),
      'secondary': Colors.amber.toARGB32(),
      'surface': Colors.white.toARGB32(),
      'background': const Color(0xFFF5F0FF).toARGB32(),
      'onPrimary': Colors.white.toARGB32(),
      'onSecondary': Colors.black.toARGB32(),
      'onSurface': Colors.black87.toARGB32(),
      'error': Colors.red.toARGB32(),
      'onError': Colors.white.toARGB32(),
    },
  ),
);
```

In the overlay, consume the palette via the stream or the static getter:

```dart
FloatyOverlay.setUp();

// Static access.
final primary = FloatyOverlay.palette?.primary;

// Reactive updates.
FloatyOverlay.onPaletteChanged.listen((palette) {
  setState(() => _bg = palette.surface ?? Colors.white);
});
```

---

## Size Presets

Instead of specifying raw pixel dimensions, use a `ContentSizePreset`:

```dart
await FloatyChatheads.showChatHead(
  // ...
  sizePreset: ContentSizePreset.halfScreen,
);
```

| Preset | Width | Height |
|---|---|---|
| `compact` | 160 dp | 200 dp |
| `card` | 300 dp | 400 dp |
| `halfScreen` | Full width | Half screen |
| `fullScreen` | Full width | Full height |

---

## Debug Inspector (Android)

Enable the native debug overlay during development:

```dart
await FloatyChatheads.showChatHead(
  // ...
  debugMode: true,
);
```

The inspector renders directly on the Android `WindowManager` layer (does not intercept
touches) and displays:

- **FPS counter** -- measured via `Choreographer.FrameCallback`
- **Spring velocity HUD** -- current rebound spring velocity of the top chathead
- **State info** -- toggled, captured, head count
- **Green bounds rectangles** around each `ChatHead` view
- **Blue bounds rectangle** around the content panel

Query debug telemetry from Dart:

```dart
final info = await FloatyOverlay.getDebugInfo();
```

---

## Accessibility (Android TalkBack)

All native views ship with built-in TalkBack support:

- **ChatHead bubbles**: content description updates with badge count
  (e.g. *"Chat bubble default, 3 new messages"*), custom accessibility actions
  for expand/collapse and dismiss
- **Close target**: live-region announcement when visible, descriptive label
- **Content panel**: receives focus on expand, announces hide on collapse
- **Motion tracker**: hidden from accessibility tree
- **Debug overlay**: excluded from accessibility

No extra Dart code is required -- accessibility is handled at the native Android layer.
For overlay-side semantics, use Flutter's standard `Semantics` widget (works on both
platforms).

---

## Configuration Options

### `showChatHead` parameters

| Parameter | Type | Default | Description | Platform |
|---|---|---|---|---|
| `entryPoint` | `String` | `'overlayMain'` | Dart function annotated with `@pragma('vm:entry-point')` | Both |
| `contentWidth` | `int?` | `null` | Content panel width (dp / pt) | Both |
| `contentHeight` | `int?` | `null` | Content panel height (dp / pt) | Both |
| `chatheadIconAsset` | `String?` | `null` | Asset path for bubble icon | Android |
| `closeIconAsset` | `String?` | `null` | Asset path for close icon | Android |
| `closeBackgroundAsset` | `String?` | `null` | Asset path for close background | Android |
| `notificationTitle` | `String?` | `null` | Foreground-service notification title | Android |
| `notificationIconAsset` | `String?` | `null` | Asset path for notification icon | Android |
| `flag` | `OverlayFlag` | `.defaultFlag` | Window behavior flag | Both |
| `enableDrag` | `bool` | `true` | Whether the bubble is draggable | Both |
| `notificationVisibility` | `NotificationVisibility` | `.visibilityPublic` | Lock-screen visibility | Android |
| `snapEdge` | `SnapEdge` | `.both` | Edge snapping mode | Android |
| `snapMargin` | `double` | `-10` | Margin from screen edge when snapped | Android |
| `persistPosition` | `bool` | `false` | Restore position across sessions | Android |
| `entranceAnimation` | `EntranceAnimation` | `.none` | Entry animation (pop, slide, fade) | Android |
| `theme` | `ChatHeadTheme?` | `null` | Theming configuration | Android |
| `sizePreset` | `ContentSizePreset?` | `null` | Named size preset (overrides width/height) | Android |
| `debugMode` | `bool` | `false` | Enable native debug inspector | Android |

---

## iOS Behavior Details

On iOS the overlay is a `UIWindow` created at `windowLevel = .alert + 1`:

- The window appears **above** your app's main content but **below** system UI
  (status bar, Control Center, etc.)
- It stays visible while your app is in the foreground but **does not persist**
  when the app is backgrounded (unlike Android's system overlay)
- Dragging uses a `UIPanGestureRecognizer` with bounds clamping and a 0.2 s
  settle animation
- The overlay renders a full `FlutterViewController` with a transparent
  background and 16 pt corner radius
- Default position: top-right corner, 16 pt from the right edge, 80 pt from
  the top

Since iOS does not have a concept equivalent to Android's `SYSTEM_ALERT_WINDOW`,
the overlay cannot float above other apps. For scenarios that require cross-app
presence, consider integrating with iOS Live Activities or PiP APIs separately.

---

## Examples

The example app ships with **12 demo screens** accessible from a gallery page:

| # | Example | Description |
|---|---|---|
| 1 | Basic | Show / close / send data |
| 2 | Messenger Chat | Bidirectional messaging |
| 3 | Mini Player | Media controls with state sync |
| 4 | Quick Actions | Click-through FAB overlay |
| 5 | Notification Counter | Reactive badge updates |
| 6 | Timer / Stopwatch | Dynamic resize, lap tracking |
| 7 | Multi-Chathead | Multiple Messenger-style bubbles |
| 8 | Dashboard | Near-fullscreen scrollable notes |
| 9 | Messenger Fullscreen | Bubble at top, full chat below |
| 10 | Features Showcase | Badge, expand/collapse, lifecycle |
| 11 | Themed Chathead | Badge colors, border, palette delivery |
| 12 | Accessibility | TalkBack labels and large touch targets |

Run the example:

```bash
cd floaty_chatheads/example
flutter run
```

---

## Architecture

```
floaty_chatheads/                    # Main package (public API, platform-agnostic)
  lib/src/
    floaty_chatheads.dart            # FloatyChatheads static class
    floaty_overlay.dart              # FloatyOverlay + OverlayColorPalette
    floaty_permission_gate.dart      # Permission gate widget

floaty_chatheads_platform_interface/
  lib/src/models/
    chat_head_config.dart            # Configuration model
    chat_head_theme.dart             # Theming model
    content_size_preset.dart         # Size preset enum

floaty_chatheads_android/
  android/src/main/kotlin/           # Native Kotlin implementation
    FloatyChatheadsPlugin.kt         # Plugin entry point
    floating_chathead/
      ChatHead.kt                    # Bubble view (badge, border, a11y)
      ChatHeads.kt                   # Layout manager + spring physics
      Close.kt                      # Close-target view
      DebugOverlayView.kt           # Debug inspector overlay
    services/
      FloatyContentJobService.kt     # Foreground service + Pigeon host
    utils/
      Managment.kt                   # Shared state (theme, debug, springs)

floaty_chatheads_ios/
  ios/.../Sources/
    FloatyCheaheadsPlugin.swift      # UIWindow overlay + pan gesture
    FloatyChatheadsApi.g.swift       # Pigeon-generated Swift bindings
```

Communication uses **Pigeon** for type-safe platform channels on both platforms,
plus a `BasicMessageChannel` relay for data messages between the main app and
overlay isolates.

---

## Migration from `floaty_chathead`

This package (`floaty_chatheads`) is the successor to the original
[`floaty_chathead`](https://pub.dev/packages/floaty_chathead) plugin.
It is a **complete rewrite** -- not a drop-in upgrade.

### What changed

| Area | `floaty_chathead` (old) | `floaty_chatheads` (new) |
|---|---|---|
| **Architecture** | Single package | Federated (main + platform_interface + android + ios) |
| **Platform channels** | Method channel | Pigeon-generated type-safe APIs |
| **iOS support** | None | `UIWindow`-based PiP overlay |
| **Theming** | None | Badge, border, shadow, close tint, overlay palette |
| **Size presets** | None | `compact`, `card`, `halfScreen`, `fullScreen` |
| **Debug tooling** | None | FPS counter, spring HUD, bounds, message log |
| **Accessibility** | None | Full TalkBack support with actions and focus management |
| **Multi-bubble** | None | Messenger-style row with add/remove by ID |
| **Badge counter** | None | Native badge, updatable from main app or overlay |
| **Expand / Collapse** | None | Programmatic + accessibility actions |
| **Snap behavior** | Basic | Spring-based with configurable edge, margin, persistence |
| **Entrance animations** | None | Pop, slide-in, fade-in |
| **Overlay messaging** | Basic | Bidirectional streams + palette delivery |

### How to migrate

1. Replace `floaty_chathead` with `floaty_chatheads: ^1.0.0` in your `pubspec.yaml`.
2. Update imports from `package:floaty_chathead/...` to `package:floaty_chatheads/floaty_chatheads.dart`.
3. Replace method calls with the new static API on `FloatyChatheads` and `FloatyOverlay`.
4. Add Android manifest permissions if not already present (see [Getting Started](#2-android-setup)).
5. Review the [Configuration Options](#configuration-options) for new parameters.

---

## Acknowledgements

- **[flutter_overlay_window](https://pub.dev/packages/flutter_overlay_window)** by Saad Farhan
  -- This project draws significant inspiration from `flutter_overlay_window` for the
  approach to hosting Flutter widgets inside system overlay windows. The overlay
  engine lifecycle, `FlutterTextureView` integration (Android), `UIWindow`-based
  PiP approach (iOS), and the `BasicMessageChannel`-based messaging pattern between
  the main app and the overlay isolate were all informed by studying that package's
  design. Thank you for pioneering a clean pattern for Flutter overlays.

- **[Facebook Rebound](https://github.com/facebookarchive/rebound)** -- Spring physics
  library used for chathead snapping and drag animations on Android.

- **[Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli)** -- Project
  scaffolding and federated plugin structure generated with Very Good CLI.

---

## License

This project is licensed under the MIT License. See [LICENSE](../LICENSE) for details.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[coverage_badge]: https://img.shields.io/badge/coverage-100%25-brightgreen.svg
[coverage_link]: #test-suite--coverage
[tests_badge]: https://img.shields.io/badge/tests-132%20passed-brightgreen.svg
[tests_link]: #test-suite--coverage
