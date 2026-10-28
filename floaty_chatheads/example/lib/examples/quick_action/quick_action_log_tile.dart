import 'package:flutter/material.dart';

import 'quick_action_log_entry.dart';

/// Card showing one logged quick action with its icon, color and time.
final class QuickActionLogTile extends StatelessWidget {
  /// Creates the tile for [entry].
  const factory QuickActionLogTile({
    required QuickActionLogEntry entry,
    Key? key,
  }) = QuickActionLogTile._;

  const QuickActionLogTile._({required this.entry, super.key});

  /// The logged action.
  final QuickActionLogEntry entry;

  String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:'
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
    final color = _colorForAction(entry.action);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(_iconForAction(entry.action), color: color),
        ),
        title: Text(
          entry.action.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        subtitle: Text(_formatTime(entry.time)),
      ),
    );
  }
}
