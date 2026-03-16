import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Badge overlay that displays a notification count.
///
/// Receives count from main app, can send 'clear' action back.
/// Uses [FloatyOverlayBuilder] to eliminate all lifecycle boilerplate.
class NotificationCounterOverlay extends StatelessWidget {
  const NotificationCounterOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayBuilder<int>(
      initialState: 0,
      onData: (count, data) =>
          data is Map && data['count'] is int ? data['count'] as int : count,
      onInit: () => FloatyOverlay.shareData({'action': 'requestState'}),
      builder: (context, count) => _CounterBadge(count: count),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final hasNotifications = count > 0;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: hasNotifications ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (hasNotifications ? Colors.red : Colors.grey)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Buttons
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  if (hasNotifications)
                    _PillButton(
                      label: 'Clear',
                      color: Colors.red,
                      onTap: () =>
                          FloatyOverlay.shareData({'action': 'clear'}),
                    ),
                  _PillButton(
                    label: 'Close',
                    color: Colors.grey.shade600,
                    onTap: FloatyOverlay.closeOverlay,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      ),
    );
  }
}
