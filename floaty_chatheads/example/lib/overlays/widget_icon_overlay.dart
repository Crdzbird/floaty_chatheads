import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Simple overlay for the widget icon example — shows a card
/// confirming the chathead is alive.
class WidgetIconOverlay extends StatelessWidget {
  const WidgetIconOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          color: Colors.indigo.shade700,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.widgets, color: Colors.white, size: 28),
                const SizedBox(height: 6),
                const Text(
                  'Widget Icon',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No image assets used!',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: FloatyOverlay.closeOverlay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
