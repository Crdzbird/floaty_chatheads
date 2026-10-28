part of '../messenger_fullscreen_example.dart';

mixin _MessengerFullscreenExampleLogic on State<MessengerFullscreenExample> {
  final _controller = TextEditingController();
  final _log = <String>[];
  StreamSubscription<Object?>? _sub;
  StreamSubscription<String>? _closeSub;
  bool _chatheadActive = false;

  void _listen() {
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || !mounted) return;
      final sender = data['sender'] ?? 'overlay';
      final text = data['text'] ?? '';
      setState(() {
        _log.insert(0, '$sender: $text');
        if (_log.length > 50) _log.removeLast();
      });
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'messengerFullscreenOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Messenger Active'),
      contentWidth: -1,
      contentHeight: -1,
    );
    setState(() => _chatheadActive = true);
  }

  void _closeChathead() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() => _chatheadActive = false);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final sent = FloatyChatheads.shareData({'sender': 'app', 'text': text});
    setState(() {
      _log.insert(0, 'you: $text');
      if (_log.length > 50) _log.removeLast();
    });
    await sent;
  }

  void _disposeLogic() {
    unawaited(_closeSub?.cancel());
    unawaited(_sub?.cancel());
    _controller.dispose();
    unawaited(FloatyChatheads.closeChatHead());
  }
}
