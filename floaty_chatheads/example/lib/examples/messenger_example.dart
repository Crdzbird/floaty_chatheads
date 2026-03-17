import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Messenger-style chat: main app has a text input, overlay shows
/// quick-reply buttons. Both sides display all messages.
class MessengerExample extends StatefulWidget {
  const MessengerExample({super.key});

  @override
  State<MessengerExample> createState() => _MessengerExampleState();
}

class _MessengerExampleState extends State<MessengerExample> {
  final _controller = TextEditingController();
  final _messages = <_Msg>[];
  final _scrollController = ScrollController();
  StreamSubscription<Object?>? _sub;
  bool _chatheadActive = false;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        setState(() {
          _messages.add(_Msg(
            sender: '${data['sender'] ?? 'overlay'}',
            text: '${data['text'] ?? ''}',
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
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

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _messages.add(_Msg(sender: 'app', text: text)));
    FloatyChatheads.shareData({'sender': 'app', 'text': text});
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger Chat'),
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
              color: Colors.indigo.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.indigo.shade400),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap the chat icon in the app bar to launch the chathead',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nSend a message below!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isApp = msg.sender == 'app';
                      return Align(
                        alignment: isApp
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isApp
                                ? Colors.indigo
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isApp ? 'You' : 'Overlay',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isApp
                                      ? Colors.white70
                                      : Colors.black45,
                                ),
                              ),
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color:
                                      isApp ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    FloatyChatheads.closeChatHead();
    super.dispose();
  }
}

class _Msg {
  _Msg({required this.sender, required this.text});
  final String sender;
  final String text;
}
