import 'package:floaty_chatheads/src/animated_widget_icon.dart';

/// Holds the animated chathead icon configured by the last show call.
final class FloatyIconAnimation {
  FloatyIconAnimation._();

  /// The active animation controller, if any.
  static AnimatedWidgetIcon? active;

  /// Whether the active animation's render loop is running.
  static bool get isRunning => active?.isRunning ?? false;

  /// Starts the active animation, if any.
  static void start() => active?.start();

  /// Stops the active animation, keeping it for a later [start].
  static void stop() => active?.stop();

  /// Stops and forgets the active animation.
  static void dispose() {
    active?.dispose();
    active = null;
  }

  /// Disposes the active animation only when it belongs to bubble [id],
  /// so closing a secondary bubble keeps the main animation alive.
  static void disposeIfOwnedBy(String id) {
    if (active?.id == id) dispose();
  }
}
