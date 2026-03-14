# floaty_chatheads_platform_interface

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

The platform interface for [`floaty_chatheads`][main_link] -- the successor to
[`floaty_chathead`](https://pub.dev/packages/floaty_chathead).

This package defines the abstract contract (`FloatyChatheadsPlatform`),
configuration models (`ChatHeadConfig`, `ChatHeadTheme`, `ContentSizePreset`,
etc.), and the method-channel fallback shared by the Android and iOS
implementations.

## Usage

To implement a new platform-specific implementation of `floaty_chatheads`,
extend `FloatyChatheadsPlatform` with an implementation that performs the
platform-specific behavior, and register it via
`FloatyChatheadsPlatform.instance`.

## Models

| Model | Description |
|---|---|
| `ChatHeadConfig` | Full overlay configuration (entry point, dimensions, flags, snap, animation, theme, debug) |
| `ChatHeadTheme` | Badge colors, bubble border, shadow, close tint, overlay palette |
| `ContentSizePreset` | Named size presets: `compact`, `card`, `halfScreen`, `fullScreen` |
| `AddChatHeadConfig` | ID + icon for adding a bubble to the group |
| `OverlayPosition` | x/y coordinates of the overlay |
| `OverlayFlag` | Window behavior flags |
| `SnapEdge` | Edge snapping mode |
| `EntranceAnimation` | Entry animation variants |
| `NotificationVisibility` | Foreground-service notification visibility |

[main_link]: https://pub.dev/packages/floaty_chatheads
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
