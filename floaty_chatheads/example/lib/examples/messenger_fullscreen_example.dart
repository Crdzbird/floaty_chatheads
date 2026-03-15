import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Facebook Messenger-style chathead: tap the bubble and the whole
/// screen below it becomes a full chat conversation panel.
class MessengerFullscreenExample extends StatefulWidget {
  const MessengerFullscreenExample({super.key});

  @override
  State<MessengerFullscreenExample> createState() =>
      _MessengerFullscreenExampleState();
}

class _MessengerFullscreenExampleState
    extends State<MessengerFullscreenExample> {
  final _controller = TextEditingController();
  final _log = <String>[];
  StreamSubscription<Object?>? _sub;
  bool _chatheadActive = false;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        final sender = data['sender'] ?? 'overlay';
        final text = data['text'] ?? '';
        setState(() {
          _log.insert(0, '$sender: $text');
          if (_log.length > 50) _log.removeLast();
        });
      }
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    // contentWidth/contentHeight = -1 → native uses MATCH_PARENT,
    // giving the overlay the full screen from the start.
    await FloatyChatheads.showChatHead(
      entryPoint: 'messengerFullscreenOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Messenger Active'),
      contentWidth: -1,
      contentHeight: -1,
    );
    setState(() => _chatheadActive = true);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    FloatyChatheads.shareData({'sender': 'app', 'text': text});
    setState(() {
      _log.insert(0, 'you: $text');
      if (_log.length > 50) _log.removeLast();
    });
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
              onPressed: _launch,
            ),
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close chathead',
              onPressed: () {
                FloatyChatheads.closeChatHead();
                setState(() => _chatheadActive = false);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_chatheadActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade400),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap the chat bubble to launch a Messenger-style '
                      'fullscreen chathead overlay.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (_chatheadActive)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Send a message to overlay...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: _send,
                    child: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Message log (${_log.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_log.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_log.clear),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _log.isEmpty
                ? const Center(
                    child: Text(
                      'Messages from the overlay will appear here.\n'
                      'Use quick replies in the overlay or\n'
                      'send messages from here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _log[i],
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
