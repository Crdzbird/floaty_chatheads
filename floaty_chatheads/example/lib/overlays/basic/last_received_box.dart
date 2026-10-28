import 'package:flutter/material.dart';

/// Translucent box showing the last payload the overlay received.
final class LastReceivedBox extends StatelessWidget {
  /// Creates the box showing [text].
  const factory LastReceivedBox({required String text, Key? key}) =
      LastReceivedBox._;

  const LastReceivedBox._({required this.text, super.key});

  /// The text to show, clipped to two lines.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
