import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'quick_action_button.dart';
import 'quick_action_item.dart';

/// The expanded column of action buttons plus a close button.
final class QuickActionStrip extends StatelessWidget {
  /// Creates the action strip.
  const factory QuickActionStrip({Key? key}) = QuickActionStrip._;

  const QuickActionStrip._({super.key});

  static const _actions = [
    QuickActionItem(Icons.camera_alt, 'screenshot', Colors.blue),
    QuickActionItem(Icons.bookmark, 'bookmark', Colors.orange),
    QuickActionItem(Icons.share, 'share', Colors.green),
    QuickActionItem(Icons.settings, 'settings', Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in _actions) ...[
                  QuickActionButton(
                    icon: action.icon,
                    color: action.color,
                    label: action.name,
                    onTap: () => unawaited(
                      FloatyOverlay.shareData({
                        'action': action.name,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                QuickActionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'close',
                  onTap: () => unawaited(FloatyOverlay.closeOverlay()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
