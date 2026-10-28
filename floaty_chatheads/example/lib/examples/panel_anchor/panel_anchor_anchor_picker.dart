import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Labeled segmented control choosing below, above or auto anchoring.
final class PanelAnchorAnchorPicker extends StatelessWidget {
  /// Creates the picker showing [anchor] as selected.
  const factory PanelAnchorAnchorPicker({
    required PanelAnchor anchor,
    required ValueChanged<PanelAnchor> onChanged,
    Key? key,
  }) = PanelAnchorAnchorPicker._;

  const PanelAnchorAnchorPicker._({
    required this.anchor,
    required this.onChanged,
    super.key,
  });

  /// The currently selected anchor.
  final PanelAnchor anchor;

  /// Called with the newly selected anchor.
  final ValueChanged<PanelAnchor> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Panel Anchor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        SegmentedButton<PanelAnchor>(
          segments: const [
            ButtonSegment(
              value: PanelAnchor.below,
              label: Text('Below'),
              icon: Icon(Icons.south),
            ),
            ButtonSegment(
              value: PanelAnchor.above,
              label: Text('Above'),
              icon: Icon(Icons.north),
            ),
            ButtonSegment(
              value: PanelAnchor.auto,
              label: Text('Auto'),
              icon: Icon(Icons.swap_vert),
            ),
          ],
          selected: {anchor},
          onSelectionChanged: (v) => onChanged(v.first),
        ),
      ],
    );
  }
}
