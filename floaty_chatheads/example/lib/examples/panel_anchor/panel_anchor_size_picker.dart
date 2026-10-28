import 'package:flutter/material.dart';

import 'panel_anchor_size.dart';

/// Labeled segmented control choosing one of the panel size presets.
final class PanelAnchorSizePicker extends StatelessWidget {
  /// Creates the picker over [sizes] with [selected] highlighted.
  const factory PanelAnchorSizePicker({
    required List<PanelAnchorSize> sizes,
    required PanelAnchorSize selected,
    required ValueChanged<PanelAnchorSize> onChanged,
    Key? key,
  }) = PanelAnchorSizePicker._;

  const PanelAnchorSizePicker._({
    required this.sizes,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The presets offered as segments.
  final List<PanelAnchorSize> sizes;

  /// The currently selected preset.
  final PanelAnchorSize selected;

  /// Called with the newly selected preset.
  final ValueChanged<PanelAnchorSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Panel Size', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SegmentedButton<PanelAnchorSize>(
          segments: [
            for (final s in sizes)
              ButtonSegment(
                value: s,
                label: Text('${s.label}\n${s.width}x${s.height}'),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (v) => onChanged(v.first),
        ),
      ],
    );
  }
}
