part of '../messenger_example.dart';

final class _MessengerExampleState extends State<MessengerExample> {
  final _controller = TextEditingController();
  final _messages = <MessengerMessage>[];
  final _scrollController = ScrollController();
  StreamSubscription<Object?>? _sub;
  StreamSubscription<String>? _closeSub;
  bool _chatheadActive = false;

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || !mounted) return;
      setState(() {
        _messages.add(
          MessengerMessage(
            sender: '${data['sender'] ?? 'overlay'}',
            text: '${data['text'] ?? ''}',
          ),
        );
      });
      _scrollController.scrollToBottomAfterFrame();
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'messengerOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Messenger Active'),
      contentWidth: 300,
      contentHeight: 400,
    );
    setState(() => _chatheadActive = true);
  }

  void _close() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() => _chatheadActive = false);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _messages.add(MessengerMessage(sender: 'app', text: text)));
    _scrollController.scrollToBottomAfterFrame();
    await FloatyChatheads.shareData({'sender': 'app', 'text': text});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger Chat'),
        actions: [
          MessengerAppBarAction(
            active: _chatheadActive,
            onLaunch: () => unawaited(_launch()),
            onClose: _close,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_chatheadActive) const MessengerHintBanner(),
          Expanded(
            child: MessengerMessageList(
              messages: _messages,
              controller: _scrollController,
            ),
          ),
          MessengerInputBar(
            controller: _controller,
            onSend: () => unawaited(_send()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_closeSub?.cancel());
    unawaited(_sub?.cancel());
    _controller.dispose();
    _scrollController.dispose();
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
