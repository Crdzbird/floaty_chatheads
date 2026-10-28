import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Segmented picker for the chathead snap edge.
final class FeaturesSnapEdgePicker extends StatelessWidget {
  /// Creates the picker showing [value].
  const factory FeaturesSnapEdgePicker({
    required SnapEdge value,
    required ValueChanged<SnapEdge> onChanged,
    Key? key,
  }) = FeaturesSnapEdgePicker._;

  const FeaturesSnapEdgePicker._({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The selected snap edge.
  final SnapEdge value;

  /// Called with the newly selected snap edge.
  final ValueChanged<SnapEdge> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SnapEdge>(
      segments: const [
        ButtonSegment(value: SnapEdge.both, label: Text('Both')),
        ButtonSegment(value: SnapEdge.left, label: Text('Left')),
        ButtonSegment(value: SnapEdge.right, label: Text('Right')),
        ButtonSegment(value: SnapEdge.none, label: Text('None')),
      ],
      selected: {value},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}
