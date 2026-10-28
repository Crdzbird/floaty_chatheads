import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Segmented picker for the chathead entrance animation.
final class FeaturesEntrancePicker extends StatelessWidget {
  /// Creates the picker showing [value].
  const factory FeaturesEntrancePicker({
    required EntranceAnimation value,
    required ValueChanged<EntranceAnimation> onChanged,
    Key? key,
  }) = FeaturesEntrancePicker._;

  const FeaturesEntrancePicker._({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The selected entrance animation.
  final EntranceAnimation value;

  /// Called with the newly selected entrance animation.
  final ValueChanged<EntranceAnimation> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<EntranceAnimation>(
      segments: const [
        ButtonSegment(value: EntranceAnimation.none, label: Text('None')),
        ButtonSegment(value: EntranceAnimation.pop, label: Text('Pop')),
        ButtonSegment(
          value: EntranceAnimation.slideFromEdge,
          label: Text('Slide'),
        ),
        ButtonSegment(value: EntranceAnimation.fade, label: Text('Fade')),
      ],
      selected: {value},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}
