import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Quick-action overlay example: floating action buttons send
/// action names back to the main app for logging.
class QuickActionExample extends StatefulWidget {
  const QuickActionExample({super.key});

  @override
  State<QuickActionExample> createState() => _QuickActionExampleState();
}

class _QuickActionExampleState extends State<QuickActionExample> {
  final _log = <_LogEntry>[];
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        final action = data['action'];
        if (action is String) {
          setState(() {
            _log.insert(
              0,
              _LogEntry(action: action, time: DateTime.now()),
            );
            if (_log.length > 100) _log.removeLast();
          });
        }
      }
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'quickActionOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Quick Actions Active'),
      contentWidth: 200,
      contentHeight: 300,
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';

  IconData _iconForAction(String action) {
    return switch (action) {
      'screenshot' => Icons.camera_alt,
      'bookmark' => Icons.bookmark,
      'share' => Icons.share,
      'settings' => Icons.settings,
      _ => Icons.touch_app,
    };
  }

  Color _colorForAction(String action) {
    return switch (action) {
      'screenshot' => Colors.blue,
      'bookmark' => Colors.orange,
      'share' => Colors.green,
      'settings' => Colors.purple,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Actions'),
        actions: [
          if (_log.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(_log.clear),
              tooltip: 'Clear log',
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launch,
        icon: const Icon(Icons.bolt),
        label: const Text('Launch'),
      ),
      body: _log.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Launch the chathead, tap to expand the bubbles, '
                      'then tap the action buttons.\n\n'
                      'Actions will be logged here in real-time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _log.length,
              itemBuilder: (_, i) {
                final entry = _log[i];
                final color = _colorForAction(entry.action);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(_iconForAction(entry.action), color: color),
                    ),
                    title: Text(
                      entry.action.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    subtitle: Text(_formatTime(entry.time)),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    FloatyChatheads.dispose();
    super.dispose();
  }
}

class _LogEntry {
  _LogEntry({required this.action, required this.time});
  final String action;
  final DateTime time;
}
