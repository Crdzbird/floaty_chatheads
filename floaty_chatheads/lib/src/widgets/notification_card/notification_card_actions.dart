part of '../floaty_notification_card.dart';

final class _NotificationCardActions extends StatelessWidget {
  const _NotificationCardActions(this.card);

  final FloatyNotificationCard card;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      for (final action in card.actions)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: TextButton(
            onPressed: action.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: card._accent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(action.label, style: const TextStyle(fontSize: 12)),
          ),
        ),
    ],
  );
}
