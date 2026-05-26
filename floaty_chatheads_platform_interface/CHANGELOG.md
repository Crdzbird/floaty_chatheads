# Changelog

## 2.0.0

> **Released as part of the floaty_chatheads 2.0 line.** See the main
> package CHANGELOG for the full migration guide.

### ✨ New shared helpers

- **`FloatyChannels`** — single source of truth for the canonical
  messenger channel name (`ni.devotion.floaty_head/messenger`). The
  Dart side, the Android Kotlin service, and the iOS Swift plugin all
  reference this constant.
- **`ChatHeadConfigResolver`** — extracts default-value resolution
  (size-preset application, snap-config fallbacks, notification
  visibility default) from the Android and iOS Dart shims. Both
  platform packages now call the resolver, eliminating ~30 lines of
  duplicated null-coalescing logic.

### 📝 Documented platform differences

- `ChatHeadAssets` documents that asset overrides are honored on
  Android only; the iOS chathead is a Flutter view, so app authors
  render icons inside the overlay entry point.

### ⚙ Toolchain (BREAKING)

- Dart SDK floor `^3.5.0`, Flutter floor `>=3.27.0`.

## 1.0.5

### ✨ Enhancements

- **Added `updateChatHeadIcon()` to the platform interface.** New abstract
  method that pushes raw RGBA pixel data to the native layer, enabling
  real-time animated chathead icons driven from Dart.
- Added matching implementation in `MethodChannelFloatyChatheads`.

### 📦 Dependencies

- Removed `package:meta` dependency -- replaced with
  `package:flutter/foundation.dart` imports across all model files.

## 1.0.4

### ✨ Enhancements

- **Added `autoLaunchOnBackground` to `ChatHeadConfig`.** When `true`,
  the chathead is automatically shown when the app goes to the
  background and dismissed when the app returns to the foreground.
- **Added `persistOnAppClose` to `ChatHeadConfig`.** When `true`, the
  overlay service uses `START_STICKY` and survives after the main app
  is killed. When `false`, the service stops itself on disconnect.

## 1.0.3

### ✨ Enhancements

- **Added `NotificationConfig.description` field.** When set, the
  foreground-service notification uses a custom title and body instead
  of the default `"<title> is running"` format.

## 1.0.2

### 📦 Metadata

- Added `example/example.md` for the pub.dev example tab.

## 1.0.1

- Documentation and metadata updates.


## 1.0.0

### 🎉 Initial Release

- `FloatyChatheadsPlatform` abstract interface with 13 platform methods.
- `ChatHeadConfig` — full configuration model with theming, size presets,
  snap behavior, entrance animations, and debug mode.
- `ChatHeadTheme` — badge colors, bubble border, shadow, close tint,
  and overlay palette.
- `ContentSizePreset` — `compact`, `card`, `halfScreen`, `fullScreen`.
- `AddChatHeadConfig`, `OverlayPosition`, `OverlayFlag`, `SnapEdge`,
  `EntranceAnimation`, `NotificationVisibility` models.
- `MethodChannelFloatyChatheads` fallback implementation.
- VGV-style `{@template}` / `{@macro}` documentation on all public APIs.
