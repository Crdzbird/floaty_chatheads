import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';
import 'quick_action_empty_hint.dart';
import 'quick_action_log_entry.dart';
import 'quick_action_log_tile.dart';

/// Page of the quick-action example: a launch button and the action log.
final class QuickActionPage extends StatelessWidget {
  /// Creates the page showing [log], newest first.
  const factory QuickActionPage({
    required List<QuickActionLogEntry> log,
    Key? key,
  }) = QuickActionPage._;

  const QuickActionPage._({required this.log, super.key});

  /// Received actions, newest first.
  final List<QuickActionLogEntry> log;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Actions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_launch()),
        icon: const Icon(Icons.bolt),
        label: const Text('Launch'),
      ),
      body: log.isEmpty
          ? const QuickActionEmptyHint()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: log.length,
              itemBuilder: (_, i) => QuickActionLogTile(entry: log[i]),
            ),
    );
  }
}
