import 'package:flutter/material.dart';

/// Title bar of the features showcase overlay with a close icon.
final class FeaturesOverlayHeader extends StatelessWidget {
  /// Creates the header; [onClose] runs when the close icon is tapped.
  const factory FeaturesOverlayHeader({
    required VoidCallback onClose,
    Key? key,
  }) = FeaturesOverlayHeader._;

  const FeaturesOverlayHeader._({required this.onClose, super.key});

  /// Called when the close icon is tapped.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Features Showcase',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }
}
