import 'package:flutter/material.dart';

/// Badge +1 and Clear controls inside the features showcase overlay.
final class FeaturesOverlayBadgeRow extends StatelessWidget {
  /// Creates the row; [count] is shown on the increment button.
  const factory FeaturesOverlayBadgeRow({
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onClear,
    Key? key,
  }) = FeaturesOverlayBadgeRow._;

  const FeaturesOverlayBadgeRow._({
    required this.count,
    required this.onIncrement,
    required this.onClear,
    super.key,
  });

  /// Current badge count.
  final int count;

  /// Called when the increment button is tapped.
  final VoidCallback onIncrement;

  /// Called when "Clear" is tapped.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onIncrement,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Badge +1 ($count)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
