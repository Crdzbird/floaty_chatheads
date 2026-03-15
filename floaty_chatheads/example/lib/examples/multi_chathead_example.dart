import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Multi-chathead example: add/remove bubbles dynamically.
///
/// Tapping the group expands them into a row (Messenger-style).
/// Each bubble has its own ID and the overlay content switches
/// based on which bubble is active.
class MultiChatheadExample extends StatefulWidget {
  const MultiChatheadExample({super.key});

  @override
  State<MultiChatheadExample> createState() => _MultiChatheadExampleState();
}

class _MultiChatheadExampleState extends State<MultiChatheadExample> {
  final _chatIds = <String>[];
  int _nextId = 1;
  final _messages = <String>[];
  String? _activeId;
  StreamSubscription<Object?>? _dataSub;

  @override
  void initState() {
    super.initState();
    _dataSub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        if (data['event'] == 'switched') {
          setState(() => _activeId = '${data['activeId']}');
        } else if (data['message'] != null) {
          setState(() {
            _messages.insert(0, '[${data['from']}] ${data['message']}');
            if (_messages.length > 50) _messages.removeLast();
          });
        }
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Chathead')),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _showChatHead,
                  icon: const Icon(Icons.bubble_chart),
                  label: const Text('Show Chathead'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addChatHead,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Bubble'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          FloatyChatheads.closeChatHead();
                          setState(() {
                            _chatIds.clear();
                            _activeId = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Close All'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active bubbles + status
          if (_activeId != null || _chatIds.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Bubbles: ${_chatIds.length + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (_activeId != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active: $_activeId',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.cyan.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_chatIds.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _chatIds.length,
                  itemBuilder: (_, i) {
                    final id = _chatIds[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Chip(
                        label: Text(id, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => _removeChatHead(id),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
              ),
          ],

          const Divider(height: 1),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Show the chathead, add bubbles,\n'
                        'then expand and tap "Send to Main"\n'
                        'in the overlay.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _messages[i],
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
    _dataSub?.cancel();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
