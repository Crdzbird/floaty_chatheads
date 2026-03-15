/// {@template entrance_animation}
/// Animation style used when the chathead first appears on screen.
/// {@endtemplate}
enum EntranceAnimation {
  /// {@template entrance_animation.none}
  /// No entrance animation -- bubble appears at its initial position.
  /// {@endtemplate}
  none,

  /// {@template entrance_animation.pop}
  /// Bubble pops in with a scale spring.
  /// {@endtemplate}
  pop,

  /// {@template entrance_animation.slide_from_edge}
  /// Bubble slides in from the nearest edge.
  /// {@endtemplate}
  slideFromEdge,

  /// {@template entrance_animation.fade}
  /// Bubble fades in.
  /// {@endtemplate}
  fade,
}
