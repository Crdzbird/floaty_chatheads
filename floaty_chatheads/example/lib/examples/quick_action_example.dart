import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'quick_action/quick_action_log_entry.dart';
import 'quick_action/quick_action_page.dart';

/// Quick-action overlay example: floating action buttons send action names
/// back to the main app for logging.
///
/// Uses [FloatyDataBuilder] so incoming actions accumulate into a log list
/// through a reducer, without a manual stream subscription.
final class QuickActionExample extends StatelessWidget {
  /// Creates the quick-action example page.
  const factory QuickActionExample({Key? key}) = QuickActionExample._;

  const QuickActionExample._({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyDataBuilder<List<QuickActionLogEntry>>(
      initialData: const [],
      onData: (log, raw) {
        if (raw is Map) {
          final action = raw['action'];
          if (action is String) {
            return [
              QuickActionLogEntry(action: action, time: DateTime.now()),
              ...log,
            ].take(100).toList();
          }
        }
        return log;
      },
      builder: (context, log) => QuickActionPage(log: log),
    );
  }
}
