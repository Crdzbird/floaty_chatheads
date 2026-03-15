# Changelog

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
