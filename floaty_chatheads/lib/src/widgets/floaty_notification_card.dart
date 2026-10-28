import 'package:floaty_chatheads/src/widgets/floaty_notification_action.dart';
import 'package:flutter/material.dart';

export 'package:floaty_chatheads/src/widgets/floaty_notification_action.dart';

part 'notification_card/notification_card_actions.dart';
part 'notification_card/notification_card_header.dart';
part 'notification_card/notification_card_surface.dart';

/// A pre-built toast-style notification card overlay, with an optional
/// leading icon, a dismiss button and action buttons.
///
/// ```dart
/// FloatyOverlayApp.run(
///   const FloatyNotificationCard(title: 'New Message', icon: Icons.message),
/// );
/// ```
final class FloatyNotificationCard extends StatelessWidget {
  /// Creates a notification card showing [title].
  const factory FloatyNotificationCard({
    required String title,
    Key? key,
    String? body,
    IconData? icon,
    Widget? iconWidget,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    List<FloatyNotificationAction> actions,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? accentColor,
    double elevation,
  }) = FloatyNotificationCard._;

  const FloatyNotificationCard._({
    required this.title,
    super.key,
    this.body,
    this.icon,
    this.iconWidget,
    this.onTap,
    this.onDismiss,
    this.actions = const [],
    this.backgroundColor,
    this.foregroundColor,
    this.accentColor,
    this.elevation = 8,
  });

  /// The notification title.
  final String title;

  /// The notification body text.
  final String? body;

  /// An [IconData] shown at the leading position.
  final IconData? icon;

  /// A custom widget shown at the leading position; wins over [icon].
  final Widget? iconWidget;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Called when the dismiss button is tapped.
  final VoidCallback? onDismiss;

  /// Optional action buttons rendered below the body.
  final List<FloatyNotificationAction> actions;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Color for text and icons.
  final Color? foregroundColor;

  /// Accent color for the icon circle and action buttons.
  final Color? accentColor;

  /// Card shadow elevation.
  final double elevation;

  Color get _foreground => foregroundColor ?? const Color(0xFF1E1E2E);

  Color get _accent => accentColor ?? const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: _NotificationCardSurface(this),
  );
}
