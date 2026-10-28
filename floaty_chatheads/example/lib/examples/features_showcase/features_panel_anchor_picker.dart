import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Segmented picker for where the panel opens relative to the bubble.
final class FeaturesPanelAnchorPicker extends StatelessWidget {
  /// Creates the picker showing [value].
  const factory FeaturesPanelAnchorPicker({
    required PanelAnchor value,
    required ValueChanged<PanelAnchor> onChanged,
    Key? key,
  }) = FeaturesPanelAnchorPicker._;

  const FeaturesPanelAnchorPicker._({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The selected panel anchor.
  final PanelAnchor value;

  /// Called with the newly selected panel anchor.
  final ValueChanged<PanelAnchor> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PanelAnchor>(
      segments: const [
        ButtonSegment(value: PanelAnchor.below, label: Text('Below')),
        ButtonSegment(value: PanelAnchor.above, label: Text('Above')),
        ButtonSegment(value: PanelAnchor.auto, label: Text('Auto')),
      ],
      selected: {value},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}
