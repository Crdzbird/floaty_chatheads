import 'package:floaty_chatheads_platform_interface/src/models/snap_edge.dart';
import 'package:flutter/foundation.dart' show immutable;

/// {@template snap_config}
/// Groups snap-behavior parameters for the chathead bubble.
///
/// ```dart
/// snap: SnapConfig(
///   edge: SnapEdge.both,
///   margin: -10,
///   persistPosition: false,
/// ),
/// ```
/// {@endtemplate}
@immutable
class SnapConfig {
  /// {@macro snap_config}
  const SnapConfig({
    this.edge = SnapEdge.both,
    this.margin = -10,
    this.persistPosition = false,
  });

  /// Which screen edge(s) the chathead snaps to after being released.
  ///
  /// Defaults to [SnapEdge.both].
  final SnapEdge edge;

  /// Margin (in dp) from the screen edge when snapped.
  ///
  /// Negative values mean the bubble overlaps the edge (partially hidden).
  /// Defaults to `-10`.
  final double margin;

  /// Whether to save and restore the chathead position across sessions.
  ///
  /// Defaults to `false`.
  final bool persistPosition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnapConfig &&
          other.edge == edge &&
          other.margin == margin &&
          other.persistPosition == persistPosition;

  @override
  int get hashCode => Object.hash(edge, margin, persistPosition);
}
