part of '../floaty_notification_card.dart';

final class _NotificationCardHeader extends StatelessWidget {
  const _NotificationCardHeader(this.card);

  final FloatyNotificationCard card;

  @override
  Widget build(BuildContext context) {
    final fg = card._foreground;
    final accent = card._accent;
    final hasIcon = card.iconWidget != null || card.icon != null;
    final body = card.body;
    return Row(
      children: [
        if (hasIcon)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: card.iconWidget ?? Icon(card.icon, color: accent, size: 20),
          ),
        if (hasIcon) const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.title,
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
                  body,
                  style: TextStyle(color: fg.withAlpha(153), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (card.onDismiss != null)
          IconButton(
            icon: Icon(Icons.close, color: fg.withAlpha(102), size: 18),
            onPressed: card.onDismiss,
            tooltip: 'Dismiss',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }
}
