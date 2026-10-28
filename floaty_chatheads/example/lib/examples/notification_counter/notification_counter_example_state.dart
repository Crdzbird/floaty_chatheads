part of '../notification_counter_example.dart';

final class _NotificationCounterExampleState
    extends State<NotificationCounterExample> {
  int _counter = 0;
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || !mounted) return;
      final action = data['action'];
      if (action == 'clear') {
        setState(() => _counter = 0);
        return;
      }
      if (action == 'requestState') unawaited(_pushCount());
    });
  }

  Future<void> _pushCount() => FloatyChatheads.shareData({'count': _counter});

  Future<void> _updateCounter(int value) async {
    setState(() => _counter = value);
    await _pushCount();
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'counterOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Counter Badge Active'),
      contentWidth: 140,
      contentHeight: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Counter')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_launch()),
        icon: const Icon(Icons.notifications),
        label: const Text('Launch Badge'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CounterDisplay(count: _counter),
            const SizedBox(height: 32),
            CounterControls(
              onDecrement: () => unawaited(_updateCounter(_counter - 1)),
              onReset: () => unawaited(_updateCounter(0)),
              onIncrement: () => unawaited(_updateCounter(_counter + 1)),
            ),
            const SizedBox(height: 16),
            Text(
              'Change the counter and watch the overlay badge update!',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
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
