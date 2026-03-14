# floaty_chatheads_android

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

The Android implementation of [`floaty_chatheads`][main_link] -- the successor to
[`floaty_chathead`](https://pub.dev/packages/floaty_chathead).

## Features

- `SYSTEM_ALERT_WINDOW` overlay with foreground service
- Facebook Rebound spring physics for drag and snap animations
- Pigeon-generated type-safe Dart ↔ Kotlin communication
- Theming: badge colors, bubble border, shadow, close tint, overlay palette
- Size presets: `compact`, `card`, `halfScreen`, `fullScreen`
- Debug inspector: FPS counter, spring HUD, bounds rectangles, Pigeon log
- Full TalkBack accessibility: content descriptions, state announcements,
  custom actions (expand/collapse, dismiss), and focus management
- Entrance animations: pop, slide-in, fade-in
- Badge counter (updatable from main app or overlay)
- Programmatic expand / collapse
- Position persistence across sessions
- Multi-bubble Messenger-style row

## Usage

This package is [endorsed][endorsed_link], which means you can simply use
`floaty_chatheads` normally. This package will be automatically included
in your app when you do.

[main_link]: https://pub.dev/packages/floaty_chatheads
[endorsed_link]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
