part of '../timer_example.dart';

final class _TimerExampleState extends State<TimerExample> {
  int _elapsedMs = 0;
  bool _isRunning = false;
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || !mounted) return;
      setState(() {
        if (data['elapsed'] is int) _elapsedMs = data['elapsed'] as int;
        if (data['isRunning'] is bool) {
          _isRunning = data['isRunning'] as bool;
        }
      });
    });
  }

  Future<void> _sendCommand(String command) =>
      FloatyChatheads.shareData({'command': command});

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'timerOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Timer Active'),
      contentWidth: 200,
      contentHeight: 160,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer / Stopwatch')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_launch()),
        icon: const Icon(Icons.timer),
        label: const Text('Launch Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TimerElapsedText(elapsedMs: _elapsedMs),
            const SizedBox(height: 8),
            TimerStatusPill(isRunning: _isRunning),
            const SizedBox(height: 32),
            TimerRemoteControls(
              isRunning: _isRunning,
              onToggle: () =>
                  unawaited(_sendCommand(_isRunning ? 'pause' : 'start')),
              onReset: () => unawaited(_sendCommand('reset')),
            ),
            const SizedBox(height: 24),
            const TimerHint(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
