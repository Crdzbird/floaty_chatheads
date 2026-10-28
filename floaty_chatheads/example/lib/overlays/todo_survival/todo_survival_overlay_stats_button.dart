import 'package:flutter/material.dart';

/// "Get Stats (proxy)" tile of the todo survival overlay with the last
/// result below it.
final class TodoSurvivalOverlayStatsButton extends StatelessWidget {
  /// Creates the tile showing [result] and calling [onTap].
  const factory TodoSurvivalOverlayStatsButton({
    required String result,
    required VoidCallback onTap,
    Key? key,
  }) = TodoSurvivalOverlayStatsButton._;

  const TodoSurvivalOverlayStatsButton._({
    required this.result,
    required this.onTap,
    super.key,
  });

  /// Last stats result; hidden while empty, red when it holds fallbacks.
  final String result;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 12,
                    color: Colors.blue.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Get Stats (proxy)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              if (result.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  result,
                  style: TextStyle(
                    fontSize: 8,
                    color: result.contains('?')
                        ? Colors.red.shade400
                        : Colors.blue.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
