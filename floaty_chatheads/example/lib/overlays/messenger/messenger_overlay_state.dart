part of '../messenger_overlay.dart';

final class _MessengerOverlayState extends State<MessengerOverlay> {
  final _messages = <MessengerMessage>[];
  late final StreamSubscription<Object?> _dataSub;
  final _scrollController = ScrollController();

  static const _quickReplies = ['Got it!', 'On my way', 'One sec', 'Call me'];

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is! Map || !mounted) return;
      setState(() {
        _messages.add(
          MessengerMessage(
            sender: '${data['sender'] ?? 'app'}',
            text: '${data['text'] ?? ''}',
          ),
        );
      });
      _scrollController.scrollToBottomAfterFrame();
    });
  }

  Future<void> _sendReply(String text) async {
    setState(
      () => _messages.add(MessengerMessage(sender: 'overlay', text: text)),
    );
    _scrollController.scrollToBottomAfterFrame();
    await FloatyOverlay.shareData({'sender': 'overlay', 'text': text});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MessengerOverlayHeader(),
              Flexible(
                child: MessengerOverlayMessageList(
                  messages: _messages,
                  controller: _scrollController,
                ),
              ),
              MessengerQuickReplies(
                replies: _quickReplies,
                onReply: (text) => unawaited(_sendReply(text)),
              ),
            ],
          ),
        ),
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
