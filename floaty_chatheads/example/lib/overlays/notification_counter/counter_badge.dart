import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'counter_pill_button.dart';

/// Badge circle with the count plus Clear and Close pill buttons.
final class CounterBadge extends StatelessWidget {
  /// Creates the badge for [count].
  const factory CounterBadge({required int count, Key? key}) = CounterBadge._;

  const CounterBadge._({required this.count, super.key});

  /// The notification count to show.
  final int count;

  @override
  Widget build(BuildContext context) {
    final hasNotifications = count > 0;
    final color = hasNotifications ? Colors.red : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
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
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  if (hasNotifications)
                    CounterPillButton(
                      label: 'Clear',
                      color: Colors.red,
                      onTap: () => unawaited(
                        FloatyOverlay.shareData({'action': 'clear'}),
                      ),
                    ),
                  CounterPillButton(
                    label: 'Close',
                    color: Colors.grey.shade600,
                    onTap: () => unawaited(FloatyOverlay.closeOverlay()),
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
