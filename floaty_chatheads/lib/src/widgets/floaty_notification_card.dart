import 'package:flutter/material.dart';

/// {@template floaty_notification_card}
/// A pre-built notification card overlay widget.
///
/// Provides an instant toast/notification-style overlay panel:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void notificationOverlay() => FloatyOverlayApp.run(
///   FloatyNotificationCard(
///     title: 'New Message',
///     body: 'You have 3 unread messages',
///     icon: Icons.message,
///     onTap: () => FloatyOverlay.shareData({'action': 'openChat'}),
///     onDismiss: FloatyOverlay.closeOverlay,
///   ),
/// );
/// ```
/// {@endtemplate}
class FloatyNotificationCard extends StatelessWidget {
  /// {@macro floaty_notification_card}
  const FloatyNotificationCard({
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

  /// {@template floaty_notification_card.title}
  /// The notification title.
  /// {@endtemplate}
  final String title;

  /// {@template floaty_notification_card.body}
  /// The notification body text.
  /// {@endtemplate}
  final String? body;

  /// {@template floaty_notification_card.icon}
  /// An [IconData] shown at the leading position.
  /// {@endtemplate}
  final IconData? icon;

  /// {@template floaty_notification_card.icon_widget}
  /// A custom widget shown at the leading position.
  /// Takes precedence over [icon].
  /// {@endtemplate}
  final Widget? iconWidget;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Called when the dismiss button is tapped.
  final VoidCallback? onDismiss;

  /// {@template floaty_notification_card.actions}
  /// Optional action buttons rendered below the body.
  /// {@endtemplate}
  final List<FloatyNotificationAction> actions;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Color for text and icons.
  final Color? foregroundColor;

  /// Accent color for the icon circle and action buttons.
  final Color? accentColor;

  /// Card shadow elevation.
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    final fg = foregroundColor ?? const Color(0xFF1E1E2E);
    final accent = accentColor ?? const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: elevation,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon.
                      if (iconWidget != null || icon != null)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: iconWidget ??
                              Icon(icon, color: accent, size: 20),
                        ),
                      if (iconWidget != null || icon != null)
                        const SizedBox(width: 12),
                      // Title + body.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (body != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                body!,
                                style: TextStyle(
                                  color: fg.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Dismiss button.
                      if (onDismiss != null)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: fg.withValues(alpha: 0.4),
                            size: 18,
                          ),
                          onPressed: onDismiss,
                          tooltip: 'Dismiss',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                    ],
                  ),
                  // Actions.
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextButton(
                            onPressed: action.onPressed,
                            style: TextButton.styleFrom(
                              foregroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              action.label,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template floaty_notification_action}
/// An action button displayed inside a [FloatyNotificationCard].
/// {@endtemplate}
class FloatyNotificationAction {
  /// {@macro floaty_notification_action}
  const FloatyNotificationAction({
    required this.label,
    required this.onPressed,
  });

  /// The button label text.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback onPressed;
}
