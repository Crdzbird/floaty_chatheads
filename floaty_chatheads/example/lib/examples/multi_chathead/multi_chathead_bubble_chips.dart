import 'package:flutter/material.dart';

/// Horizontal list of removable chips, one per added bubble.
final class MultiChatheadBubbleChips extends StatelessWidget {
  /// Creates chips for [ids]; [onRemove] receives the deleted id.
  const factory MultiChatheadBubbleChips({
    required List<String> ids,
    required ValueChanged<String> onRemove,
    Key? key,
  }) = MultiChatheadBubbleChips._;

  const MultiChatheadBubbleChips._({
    required this.ids,
    required this.onRemove,
    super.key,
  });

  /// IDs of the added bubbles.
  final List<String> ids;

  /// Called with the id of the chip whose delete icon was tapped.
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ids.length,
        itemBuilder: (_, i) {
          final id = ids[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              label: Text(id, style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => onRemove(id),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
