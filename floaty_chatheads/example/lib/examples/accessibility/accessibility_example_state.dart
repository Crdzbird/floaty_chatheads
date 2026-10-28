part of '../accessibility_example.dart';

final class _AccessibilityExampleState extends State<AccessibilityExample> {
  final _events = <String>[];
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (!mounted) return;
      setState(() {
        _events.insert(0, '$data');
        if (_events.length > 30) _events.removeLast();
      });
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'accessibilityOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Accessibility Test'),
      contentWidth: 200,
      contentHeight: 240,
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await FloatyChatheads.updateBadge(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility / TalkBack')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_launch()),
        icon: const Icon(Icons.accessibility_new),
        label: const Text('Launch'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AccessibilityGuideCard(),
            const SizedBox(height: 12),
            const AccessibilityControls(),
            const SizedBox(height: 16),
            AccessibilityEventLog(events: _events),
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
