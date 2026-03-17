# Floaty Chatheads Platform Interface Example

This package defines the abstract contract for `floaty_chatheads`.
It is not intended for direct use — add
[floaty_chatheads](https://pub.dev/packages/floaty_chatheads) to your
`pubspec.yaml` instead.

```dart
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Create a configuration for a floating chathead.
final config = ChatHeadConfig(
  entryPoint: 'overlayMain',
  contentWidth: 300,
  contentHeight: 400,
  theme: ChatHeadTheme(
    badgeBackgroundColor: 0xFFFF0000,
    badgeTextColor: 0xFFFFFFFF,
  ),
  snapConfig: SnapConfig(
    edge: SnapEdge.nearest,
    margin: 12,
    persistPosition: true,
  ),
);
```

See the [floaty_chatheads](https://pub.dev/packages/floaty_chatheads) package
for full usage examples.
