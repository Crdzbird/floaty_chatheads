import 'package:flutter/foundation.dart';

/// One action received from the quick-action overlay.
@immutable
final class QuickActionLogEntry {
  /// Creates a log entry for [action] received at [time].
  const factory QuickActionLogEntry({
    required String action,
    required DateTime time,
  }) = QuickActionLogEntry._;

  const QuickActionLogEntry._({required this.action, required this.time});

  /// Name of the action, for example `share`.
  final String action;

  /// When the action arrived.
  final DateTime time;
}
