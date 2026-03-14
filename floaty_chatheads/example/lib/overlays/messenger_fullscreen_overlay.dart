import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Facebook Messenger-style fullscreen overlay.
///
/// The chathead bubble sits above this panel (rendered by native Android).
/// The content panel fills the full screen; a transparent top spacer reserves
/// room for the bubble row so the chat UI starts just below it.
class MessengerFullscreenOverlay extends StatefulWidget {
  const MessengerFullscreenOverlay({super.key});

  @override
  State<MessengerFullscreenOverlay> createState() =>
      _MessengerFullscreenOverlayState();
}

class _MessengerFullscreenOverlayState
    extends State<MessengerFullscreenOverlay> {
  final _messages = <_ChatMsg>[
    _ChatMsg(text: 'Hey! How are you?', isMe: false, time: '10:30 AM'),
    _ChatMsg(
      text: "I'm good! Working on the project",
      isMe: true,
      time: '10:31 AM',
    ),
    _ChatMsg(text: "Nice, how's it going?", isMe: false, time: '10:31 AM'),
    _ChatMsg(
      text: 'Pretty well! Almost done with the chat overlay feature',
      isMe: true,
      time: '10:32 AM',
    ),
    _ChatMsg(
      text: 'That sounds awesome! Can I see a demo?',
      isMe: false,
      time: '10:33 AM',
    ),
  ];

  late final StreamSubscription<Object?> _dataSub;
  final _scrollController = ScrollController();

  static const _quickReplies = [
    'Sure!',
    'One moment',
    'On it',
    'Sounds good',
  ];

  /// Height reserved for the native chathead bubble row above the content.
  /// CHAT_HEAD_SIZE(64dp) + CHAT_HEAD_EXPANDED_MARGIN_TOP(4dp) + padding.
  static const _bubbleTopSpacing = 72.0;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    // No resizeContent call needed — the native side already started
    // the panel at MATCH_PARENT (contentWidth/contentHeight omitted
    // in showChatHead).

    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is Map && data['text'] != null && mounted) {
        setState(() {
          _messages.add(_ChatMsg(
            text: '${data['text']}',
            isMe: false,
            time: TimeOfDay.now().format(context),
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
    setState(() {
      _messages.add(_ChatMsg(
        text: text,
        isMe: true,
        time: TimeOfDay.now().format(context),
      ));
    });
    FloatyOverlay.shareData({'sender': 'overlay', 'text': text});
    _scrollToBottom();
  }

  // Messenger brand colors
  static const _messengerBlue = Color(0xFF0084FF);
  static const _bgColor = Color(0xFFFFFFFF);
  static const _headerBg = Color(0xFFF5F5F5);
  static const _receivedBubble = Color(0xFFE9E9EB);
  static const _textDark = Color(0xFF1C1E21);
  static const _textLight = Color(0xFF65676B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          // Transparent spacer — the native chathead bubble sits here.
          const SizedBox(height: _bubbleTopSpacing),
          // Chat content fills the rest of the screen.
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: const BoxDecoration(
                      color: _headerBg,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _messengerBlue,
                                _messengerBlue.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name & status
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alex Johnson',
                                style: TextStyle(
                                  color: _textDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 8, color: Color(0xFF31A24C)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Active now',
                                    style: TextStyle(
                                        color: _textLight, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Phone icon
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_rounded,
                                size: 20, color: _messengerBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Video icon
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.videocam_rounded,
                                size: 20, color: _messengerBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Close
                        GestureDetector(
                          onTap: FloatyOverlay.closeOverlay,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 20, color: _textLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        final showAvatar =
                            !msg.isMe && (i == 0 || _messages[i - 1].isMe);
                        return _MessageBubble(
                            msg: msg, showAvatar: showAvatar);
                      },
                    ),
                  ),
                  // Quick reply bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    decoration: const BoxDecoration(
                      color: _headerBg,
                      border: Border(
                        top: BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick replies',
                          style: TextStyle(
                            color: _textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickReplies
                              .map((text) => GestureDetector(
                                    onTap: () => _sendReply(text),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _messengerBlue,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
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
    _dataSub.cancel();
    _scrollController.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Message bubble widget
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg, required this.showAvatar});

  final _ChatMsg msg;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 6,
        left: msg.isMe ? 48 : 0,
        right: msg.isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe)
            SizedBox(
              width: 30,
              child: showAvatar
                  ? Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _MessengerFullscreenOverlayState._messengerBlue,
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMe
                    ? _MessengerFullscreenOverlayState._messengerBlue
                    : _MessengerFullscreenOverlayState._receivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isMe
                          ? Colors.white
                          : _MessengerFullscreenOverlayState._textDark,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    msg.time,
                    style: TextStyle(
                      color: msg.isMe
                          ? Colors.white.withValues(alpha: 0.6)
                          : _MessengerFullscreenOverlayState._textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _ChatMsg {
  _ChatMsg({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;
}
