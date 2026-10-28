part of '../timer_overlay.dart';

final class _TimerOverlayState extends State<TimerOverlay>
    with _TimerOverlayLogic {
  late final StreamSubscription<Object?> _dataSub;
  late final StreamSubscription<String> _tapSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is! Map || !mounted) return;
      switch (data['command']) {
        case 'start':
          _start();
        case 'pause':
          _pause();
        case 'reset':
          _reset();
      }
    });
    _tapSub = FloatyOverlay.onTapped.listen((_) => _toggle());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(6),
          color: Colors.blueGrey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTimerOverlay(_stopwatch.elapsed),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                TimerOverlayControls(
                  isRunning: _stopwatch.isRunning,
                  onToggle: _stopwatch.isRunning ? _pause : _start,
                  onReset: _reset,
                  onLap: _lap,
                ),
                if (_laps.isNotEmpty) TimerOverlayLaps(laps: _laps),
                const SizedBox(height: 2),
                const TimerOverlayCloseLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(_dataSub.cancel());
    unawaited(_tapSub.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
