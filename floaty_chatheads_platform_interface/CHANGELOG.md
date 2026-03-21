# Changelog

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
