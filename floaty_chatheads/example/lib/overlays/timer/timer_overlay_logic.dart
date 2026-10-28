part of '../timer_overlay.dart';

mixin _TimerOverlayLogic on State<TimerOverlay> {
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  final _laps = <Duration>[];

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
      unawaited(_pushState());
    });
    unawaited(_pushState());
  }

  void _pause() {
    _stopwatch.stop();
    _ticker?.cancel();
    if (mounted) setState(() {});
    unawaited(_pushState());
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    _ticker?.cancel();
    _laps.clear();
    if (mounted) setState(() {});
    unawaited(_pushState());
  }

  void _toggle() => _stopwatch.isRunning ? _pause() : _start();

  void _lap() {
    if (!_stopwatch.isRunning) return;
    setState(() => _laps.add(_stopwatch.elapsed));
  }

  Future<void> _pushState() => FloatyOverlay.shareData({
    'elapsed': _stopwatch.elapsedMilliseconds,
    'isRunning': _stopwatch.isRunning,
  });
}
