# floaty_chatheads_ios

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

The iOS implementation of [`floaty_chatheads`][main_link] -- the successor to
[`floaty_chathead`](https://pub.dev/packages/floaty_chathead).

## Features

- `UIWindow`-based PiP overlay at `windowLevel = .alert + 1`
- No special permissions required
- Pigeon-generated type-safe Dart ↔ Swift communication
- `UIPanGestureRecognizer` for bubble drag with bounds clamping
- Separate `FlutterEngine` + `FlutterViewController` for overlay content
- Bidirectional messaging between main app and overlay isolate
- Content panel resize, overlay flag updates, and position queries
- Multi-bubble add / remove by ID
- iOS 13.0+ / Swift 6.1+

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
