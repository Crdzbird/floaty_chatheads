import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Overlay for the multi-chathead example.
///
/// Switches content based on which chathead bubble is active.
/// Each bubble ID maps to a different color and greeting.
class MultiChatOverlay extends StatefulWidget {
  const MultiChatOverlay({super.key});

  @override
  State<MultiChatOverlay> createState() => _MultiChatOverlayState();
}

class _MultiChatOverlayState extends State<MultiChatOverlay> {
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
      if (mounted) {
        setState(() => _activeId = id);
        // Notify main app which bubble is active.
        FloatyOverlay.shareData({'event': 'switched', 'activeId': id});
      }
    });

    _dataSub = FloatyOverlay.onData.listen((data) {
      // Handle data from main app if needed.
    });
  }

  void _sendMessage() {
    _messageCount++;
    FloatyOverlay.shareData({
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  _activeId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap another bubble to switch',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Send to Main',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: FloatyOverlay.closeOverlay,
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tapSub.cancel();
    _dataSub.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
