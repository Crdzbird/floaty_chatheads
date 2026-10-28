import 'package:flutter/material.dart';

/// One action offered by the quick-action overlay.
@immutable
final class QuickActionItem {
  /// Creates an action named [name] drawn with [icon] and [color].
  const factory QuickActionItem(IconData icon, String name, Color color) =
      QuickActionItem._;

  const QuickActionItem._(this.icon, this.name, this.color);

  /// Icon shown on the button.
  final IconData icon;

  /// Action name sent to the main app.
  final String name;

  /// Button background color.
  final Color color;
}
