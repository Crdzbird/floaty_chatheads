import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Decodes the `{'x': num, 'y': num}` map returned by the host API.
extension OverlayPositionMapper on Map<String?, Object?> {
  /// Returns the [OverlayPosition] described by this map.
  OverlayPosition toOverlayPosition() {
    return OverlayPosition(
      x: (this['x']! as num).toDouble(),
      y: (this['y']! as num).toDouble(),
    );
  }
}
