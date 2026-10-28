import 'package:flutter/material.dart';

/// Tappable box that requests the server time and shows the result.
final class SurvivalServerTimeButton extends StatelessWidget {
  /// Creates the box showing the last proxy [result].
  const factory SurvivalServerTimeButton({
    required String result,
    required VoidCallback onTap,
    Key? key,
  }) = SurvivalServerTimeButton._;

  const SurvivalServerTimeButton._({
    required this.result,
    required this.onTap,
    super.key,
  });

  /// The last proxy result, empty before the first call.
  final String result;

  /// Called when the box is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
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
                    Icons.access_time,
                    size: 14,
                    color: Colors.blue.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Get Server Time',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              if (result.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  result,
                  style: TextStyle(
                    fontSize: 8,
                    color: result.contains('offline')
                        ? Colors.red.shade400
                        : Colors.blue.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
