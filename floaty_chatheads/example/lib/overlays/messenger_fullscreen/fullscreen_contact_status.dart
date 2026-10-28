import 'package:flutter/material.dart';

import 'fullscreen_colors.dart';

/// Contact name with an "Active now" status line.
final class FullscreenContactStatus extends StatelessWidget {
  /// Creates the name and status block.
  const factory FullscreenContactStatus({Key? key}) = FullscreenContactStatus._;

  const FullscreenContactStatus._({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alex Johnson',
          style: TextStyle(
            color: fullscreenTextDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: Color(0xFF31A24C)),
            SizedBox(width: 4),
            Text(
              'Active now',
              style: TextStyle(color: fullscreenTextLight, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
