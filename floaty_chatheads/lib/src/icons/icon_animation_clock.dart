import 'dart:async';

/// Periodic timer plus stopwatch that drives an animated icon.
final class IconAnimationClock {
  /// Creates a stopped clock.
  factory IconAnimationClock() = IconAnimationClock._;

  IconAnimationClock._();

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  /// Whether the clock is ticking.
  bool get isRunning => _timer != null;

  /// Restarts the stopwatch and calls [onTick] [fps] times per second.
  void start(int fps, void Function() onTick) {
    _stopwatch
      ..reset()
      ..start();
    final interval = Duration(milliseconds: 1000 ~/ fps);
    _timer = Timer.periodic(interval, (_) => onTick());
  }

  /// Stops ticking.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  /// Position within the current [cycle], from 0.0 up to 1.0.
  double progress(Duration cycle) {
    final micros = cycle.inMicroseconds;
    return (_stopwatch.elapsedMicroseconds % micros) / micros;
  }
}
