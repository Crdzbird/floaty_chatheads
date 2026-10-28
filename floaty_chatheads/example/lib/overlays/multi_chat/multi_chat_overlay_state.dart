part of '../multi_chat_overlay.dart';

final class _MultiChatOverlayState extends State<MultiChatOverlay> {
  String _activeId = 'default';
  int _messageCount = 0;
  late final StreamSubscription<String> _tapSub;
  late final StreamSubscription<Object?> _dataSub;

  static const _palette = [
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.purple,
    Colors.pink,
    Colors.amber,
  ];

  Color get _color {
    final hash = _activeId.hashCode.abs();
    return _palette[hash % _palette.length];
  }

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _tapSub = FloatyOverlay.onTapped.listen((id) {
      if (!mounted) return;
      setState(() => _activeId = id);
      unawaited(
        FloatyOverlay.shareData({'event': 'switched', 'activeId': id}),
      );
    });
    _dataSub = FloatyOverlay.onData.listen((_) {});
  }

  Future<void> _sendMessage() async {
    _messageCount++;
    await FloatyOverlay.shareData({
      'from': _activeId,
      'message': 'Message #$_messageCount from $_activeId',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(8),
          color: _color,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: MultiChatCardBody(
              activeId: _activeId,
              onSend: () => unawaited(_sendMessage()),
              onClose: () => unawaited(FloatyOverlay.closeOverlay()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_tapSub.cancel());
    unawaited(_dataSub.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
