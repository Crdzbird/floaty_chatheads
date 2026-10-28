part of '../messenger_fullscreen_overlay.dart';

final class _MessengerFullscreenOverlayState
    extends State<MessengerFullscreenOverlay> {
  final _messages = fullscreenSeedMessages();
  late final StreamSubscription<Object?> _dataSub;
  final _scrollController = ScrollController();

  static const _quickReplies = ['Sure!', 'One moment', 'On it', 'Sounds good'];
  static const _bubbleTopSpacing = 72.0;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is! Map || data['text'] == null || !mounted) return;
      _addMessage('${data['text']}', isMe: false);
      _scrollToBottom();
    });
  }

  void _addMessage(String text, {required bool isMe}) {
    setState(() {
      _messages.add(
        FullscreenChatMessage(
          text: text,
          isMe: isMe,
          time: TimeOfDay.now().format(context),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_scrollController.hasClients) return;
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendReply(String text) async {
    _addMessage(text, isMe: true);
    final sent = FloatyOverlay.shareData({'sender': 'overlay', 'text': text});
    _scrollToBottom();
    await sent;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: _bubbleTopSpacing),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: fullscreenBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const FullscreenProfileHeader(),
                  Expanded(
                    child: FullscreenMessageList(
                      controller: _scrollController,
                      messages: _messages,
                    ),
                  ),
                  FullscreenQuickReplies(
                    replies: _quickReplies,
                    onReply: (text) => unawaited(_sendReply(text)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_dataSub.cancel());
    _scrollController.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
