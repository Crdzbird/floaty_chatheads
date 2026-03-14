import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Compact messenger overlay with quick-reply chips and message display.
///
/// Uses tap-to-send buttons instead of TextField (text input inside
/// Android overlays is unreliable).
class MessengerOverlay extends StatefulWidget {
  const MessengerOverlay({super.key});

  @override
  State<MessengerOverlay> createState() => _MessengerOverlayState();
}

class _MessengerOverlayState extends State<MessengerOverlay> {
  final _messages = <_Msg>[];
  late final StreamSubscription<Object?> _dataSub;
  final _scrollController = ScrollController();

  static const _quickReplies = ['Got it!', 'On my way', 'One sec', 'Call me'];

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is Map && mounted) {
        setState(() {
          _messages.add(_Msg(
            sender: '${data['sender'] ?? 'app'}',
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

  void _sendReply(String text) {
    setState(() => _messages.add(_Msg(sender: 'overlay', text: text)));
    FloatyOverlay.shareData({'sender': 'overlay', 'text': text});
    _scrollToBottom();
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
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.indigo,
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              // Messages
              Flexible(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Messages appear here',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = msg.sender == 'overlay';
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.indigo
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color:
                                      isMe ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Quick replies
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _quickReplies
                      .map(
                        (text) => GestureDetector(
                          onTap: () => _sendReply(text),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.indigo.shade200,
                              ),
                            ),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataSub.cancel();
    _scrollController.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

class _Msg {
  _Msg({required this.sender, required this.text});
  final String sender;
  final String text;
}
