part of '../messenger_fullscreen_example.dart';

final class _MessengerFullscreenExampleState
    extends State<MessengerFullscreenExample>
    with _MessengerFullscreenExampleLogic {
  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger Fullscreen'),
        actions: [
          if (!_chatheadActive)
            IconButton(
              icon: const Icon(Icons.chat_bubble),
              tooltip: 'Launch chathead',
              onPressed: () => unawaited(_launch()),
            ),
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close chathead',
              onPressed: _closeChathead,
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_chatheadActive)
            const DashboardInfoBanner(
              text:
                  'Tap the chat bubble to launch a Messenger-style '
                  'fullscreen chathead overlay.',
            ),
          if (_chatheadActive)
            MessengerFullscreenComposer(
              controller: _controller,
              onSend: () => unawaited(_send()),
            ),
          const Divider(height: 1),
          DashboardLogHeader(
            label: 'Message log',
            count: _log.length,
            onClear: () => setState(_log.clear),
          ),
          Expanded(
            child: DashboardLogList(
              entries: _log,
              fontSize: 13,
              emptyText:
                  'Messages from the overlay will appear here.\n'
                  'Use quick replies in the overlay or\n'
                  'send messages from here.',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeLogic();
    super.dispose();
  }
}
