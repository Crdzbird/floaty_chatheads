import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Badge overlay that displays a notification count.
///
/// Receives count from main app, can send 'clear' action back.
class NotificationCounterOverlay extends StatefulWidget {
  const NotificationCounterOverlay({super.key});

  @override
  State<NotificationCounterOverlay> createState() =>
      _NotificationCounterOverlayState();
}

class _NotificationCounterOverlayState
    extends State<NotificationCounterOverlay> {
  int _count = 0;
  late final StreamSubscription<Object?> _sub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    _sub = FloatyOverlay.onData.listen((data) {
      if (data is Map && mounted) {
        final count = data['count'];
        if (count is int) {
          setState(() => _count = count);
        }
      }
    });

    // Request current count from main app.
    FloatyOverlay.shareData({'action': 'requestState'});
  }

  void _clear() {
    FloatyOverlay.shareData({'action': 'clear'});
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _count > 0;

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
                    '$_count',
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
                    GestureDetector(
                      onTap: _clear,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: FloatyOverlay.closeOverlay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
