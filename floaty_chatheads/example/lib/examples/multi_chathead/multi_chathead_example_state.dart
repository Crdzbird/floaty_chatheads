part of '../multi_chathead_example.dart';

final class _MultiChatheadExampleState extends State<MultiChatheadExample> {
  final _chatIds = <String>[];
  int _nextId = 1;
  final _messages = <String>[];
  String? _activeId;
  StreamSubscription<Object?>? _dataSub;

  @override
  void initState() {
    super.initState();
    _dataSub = FloatyChatheads.onData.listen(_onData);
  }

  void _onData(Object? data) {
    if (data is! Map || !mounted) return;
    if (data['event'] == 'switched') {
      setState(() => _activeId = '${data['activeId']}');
      return;
    }
    if (data['message'] == null) return;
    setState(() {
      _messages.insert(0, '[${data['from']}] ${data['message']}');
      if (_messages.length > 50) _messages.removeLast();
    });
  }

  Future<void> _showChatHead() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'multiChatOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Multi-Chat Active'),
      contentWidth: 240,
      contentHeight: 220,
    );
    setState(() {
      _chatIds.clear();
      _activeId = 'default';
    });
  }

  Future<void> _addChatHead() async {
    final id = 'chat_$_nextId';
    _nextId++;
    await FloatyChatheads.addChatHead(id: id);
    setState(() => _chatIds.add(id));
  }

  Future<void> _removeChatHead(String id) async {
    await FloatyChatheads.removeChatHead(id);
    setState(() => _chatIds.remove(id));
  }

  void _closeAll() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() {
      _chatIds.clear();
      _activeId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Chathead')),
      body: Column(
        children: [
          MultiChatheadControls(
            onShow: () => unawaited(_showChatHead()),
            onAdd: () => unawaited(_addChatHead()),
            onCloseAll: _closeAll,
          ),
          if (_activeId != null || _chatIds.isNotEmpty) ...[
            const Divider(height: 1),
            MultiChatheadStatus(
              bubbleCount: _chatIds.length + 1,
              activeId: _activeId,
            ),
            if (_chatIds.isNotEmpty)
              MultiChatheadBubbleChips(
                ids: _chatIds,
                onRemove: (id) => unawaited(_removeChatHead(id)),
              ),
          ],
          const Divider(height: 1),
          Expanded(child: MultiChatheadMessageList(messages: _messages)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_dataSub?.cancel());
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
