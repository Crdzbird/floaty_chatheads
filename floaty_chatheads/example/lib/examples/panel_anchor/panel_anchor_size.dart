import 'package:flutter/foundation.dart';

/// A named panel size offered by the panel anchor playground.
@immutable
final class PanelAnchorSize {
  /// Creates a size preset called [label] of [width] by [height].
  const factory PanelAnchorSize({
    required String label,
    required int width,
    required int height,
  }) = PanelAnchorSize._;

  const PanelAnchorSize._({
    required this.label,
    required this.width,
    required this.height,
  });

  /// Name shown on the segment.
  final String label;

  /// Panel width in logical pixels.
  final int width;

  /// Panel height in logical pixels.
  final int height;
}
