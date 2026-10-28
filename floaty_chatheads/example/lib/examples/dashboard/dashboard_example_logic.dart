part of '../dashboard_example.dart';

mixin _DashboardExampleLogic on State<DashboardExample> {
  final _log = <String>[];
  StreamSubscription<Object?>? _sub;
  StreamSubscription<String>? _closeSub;
  bool _chatheadActive = false;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  void _listen() {
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || !mounted) return;
      final event = data['event'] ?? 'unknown';
      final title = data['title'] ?? '';
      setState(() {
        _log.insert(0, '$event: $title (${data['count']} notes)');
        if (_log.length > 30) _log.removeLast();
      });
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'dashboardOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Dashboard Active'),
      contentWidth: -1,
      contentHeight: -1,
    );
    setState(() => _chatheadActive = true);
  }

  void _closeChathead() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() => _chatheadActive = false);
  }

  Future<void> _pushNote() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty) return;
    _titleController.clear();
    _bodyController.clear();
    await FloatyChatheads.shareData({
      'action': 'addNote',
      'title': title,
      'body': body.isEmpty ? 'Sent from main app' : body,
    });
  }

  void _disposeLogic() {
    unawaited(_closeSub?.cancel());
    unawaited(_sub?.cancel());
    _titleController.dispose();
    _bodyController.dispose();
    unawaited(FloatyChatheads.closeChatHead());
  }
}
