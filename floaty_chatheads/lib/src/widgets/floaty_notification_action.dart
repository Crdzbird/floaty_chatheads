import 'package:flutter/widgets.dart';

/// An action button displayed inside a `FloatyNotificationCard`.
final class FloatyNotificationAction {
  /// Creates an action labelled [label] that runs [onPressed].
  const factory FloatyNotificationAction({
    required String label,
    required VoidCallback onPressed,
  }) = FloatyNotificationAction._;

  const FloatyNotificationAction._({
    required this.label,
    required this.onPressed,
  });

  /// The button label text.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback onPressed;
}
