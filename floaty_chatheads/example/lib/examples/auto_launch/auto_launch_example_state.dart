part of '../auto_launch_example.dart';

final class _AutoLaunchExampleState extends State<AutoLaunchExample> {
  bool _autoLaunch = true;
  bool _persist = false;
  bool _enabled = false;
  StreamSubscription<String>? _closeSub;

  Future<void> _enable() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(
        title: 'Auto-Launch Demo',
        description: 'Chathead will appear when you leave the app.',
        iconAsset: 'assets/notificationIcon.png',
      ),
      contentWidth: 260,
      contentHeight: 180,
      autoLaunchOnBackground: _autoLaunch,
      persistOnAppClose: _persist,
    );
    await _closeSub?.cancel();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _enabled = false);
    });
    setState(() => _enabled = true);
  }

  Future<void> _disable() async {
    await FloatyChatheads.closeChatHead();
    setState(() => _enabled = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Launch & Persist')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AutoLaunchSwitches(
              autoLaunch: _autoLaunch,
              persist: _persist,
              onAutoLaunchChanged: _enabled
                  ? null
                  : (v) => setState(() => _autoLaunch = v),
              onPersistChanged: _enabled
                  ? null
                  : (v) => setState(() => _persist = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => unawaited(_enabled ? _disable() : _enable()),
              icon: Icon(_enabled ? Icons.stop : Icons.play_arrow),
              label: Text(_enabled ? 'Disable' : 'Enable'),
            ),
            const SizedBox(height: 32),
            const Expanded(child: AutoLaunchInstructions()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_closeSub?.cancel());
    if (_enabled) unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
