import 'package:flutter/painting.dart';

/// A note shown on the dashboard overlay.
final class DashboardNote {
  /// Creates a note; [pinned] notes show a pin icon.
  const factory DashboardNote({
    required String title,
    required String body,
    required Color color,
    bool pinned,
  }) = DashboardNote._;

  const DashboardNote._({
    required this.title,
    required this.body,
    required this.color,
    this.pinned = false,
  });

  /// Note title.
  final String title;

  /// Note body text.
  final String body;

  /// Accent color of the card.
  final Color color;

  /// Whether the note is pinned.
  final bool pinned;
}
