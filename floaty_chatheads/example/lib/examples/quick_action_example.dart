import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Quick-action overlay example: floating action buttons send
/// action names back to the main app for logging.
///
/// Uses [FloatyDataBuilder] to eliminate manual stream subscription
/// boilerplate — incoming actions accumulate into a log list via reducer.
class QuickActionExample extends StatelessWidget {
  const QuickActionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyDataBuilder<List<_LogEntry>>(
      initialData: const [],
      onData: (log, raw) {
        if (raw is Map) {
          final action = raw['action'];
          if (action is String) {
            return [
              _LogEntry(action: action, time: DateTime.now()),
              ...log,
            ].take(100).toList();
          }
        }
        return log;
      },
      builder: (context, log) => _QuickActionPage(log: log),
    );
  }
}

class _QuickActionPage extends StatelessWidget {
  const _QuickActionPage({required this.log});
  final List<_LogEntry> log;

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
      appBar: AppBar(title: const Text('Quick Actions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launch,
        icon: const Icon(Icons.bolt),
        label: const Text('Launch'),
      ),
      body: log.isEmpty
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
              itemCount: log.length,
              itemBuilder: (_, i) {
                final entry = log[i];
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
}

class _LogEntry {
  _LogEntry({required this.action, required this.time});
  final String action;
  final DateTime time;
}
