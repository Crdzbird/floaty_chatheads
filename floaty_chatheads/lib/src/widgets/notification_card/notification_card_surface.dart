part of '../floaty_notification_card.dart';

final class _NotificationCardSurface extends StatelessWidget {
  const _NotificationCardSurface(this.card);

  final FloatyNotificationCard card;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: card.backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(38),
          blurRadius: card.elevation,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: card.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationCardHeader(card),
              if (card.actions.isNotEmpty) ...[
                const SizedBox(height: 10),
                _NotificationCardActions(card),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
