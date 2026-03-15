/// {@template snap_edge}
/// Which screen edge(s) the chathead snaps to after being released.
/// {@endtemplate}
enum SnapEdge {
  /// {@template snap_edge.both}
  /// Snap to the nearest horizontal edge (left or right). Default.
  /// {@endtemplate}
  both,

  /// {@template snap_edge.left}
  /// Always snap to the left edge.
  /// {@endtemplate}
  left,

  /// {@template snap_edge.right}
  /// Always snap to the right edge.
  /// {@endtemplate}
  right,

  /// {@template snap_edge.none}
  /// No snapping -- the bubble stays where the user releases it.
  /// {@endtemplate}
  none,
}
