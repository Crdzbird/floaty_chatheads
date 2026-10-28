import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'features_entrance_picker.dart';
import 'features_panel_anchor_picker.dart';
import 'features_section_label.dart';
import 'features_snap_edge_picker.dart';

/// Snap edge, panel anchor, entrance animation and persist position
/// options applied the next time the chathead is shown.
final class FeaturesOptionsPanel extends StatelessWidget {
  /// Creates the options panel with the current values and change hooks.
  const factory FeaturesOptionsPanel({
    required SnapEdge snapEdge,
    required PanelAnchor panelAnchor,
    required EntranceAnimation entranceAnimation,
    required bool persistPosition,
    required ValueChanged<SnapEdge> onSnapEdge,
    required ValueChanged<PanelAnchor> onPanelAnchor,
    required ValueChanged<EntranceAnimation> onEntranceAnimation,
    required ValueChanged<bool> onPersistPosition,
    Key? key,
  }) = FeaturesOptionsPanel._;

  const FeaturesOptionsPanel._({
    required this.snapEdge,
    required this.panelAnchor,
    required this.entranceAnimation,
    required this.persistPosition,
    required this.onSnapEdge,
    required this.onPanelAnchor,
    required this.onEntranceAnimation,
    required this.onPersistPosition,
    super.key,
  });

  /// Selected snap edge.
  final SnapEdge snapEdge;

  /// Selected panel anchor.
  final PanelAnchor panelAnchor;

  /// Selected entrance animation.
  final EntranceAnimation entranceAnimation;

  /// Whether the bubble position is remembered across sessions.
  final bool persistPosition;

  /// Called with a newly selected snap edge.
  final ValueChanged<SnapEdge> onSnapEdge;

  /// Called with a newly selected panel anchor.
  final ValueChanged<PanelAnchor> onPanelAnchor;

  /// Called with a newly selected entrance animation.
  final ValueChanged<EntranceAnimation> onEntranceAnimation;

  /// Called when the persist position switch is toggled.
  final ValueChanged<bool> onPersistPosition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FeaturesSectionLabel(text: 'Snap Edge'),
        const SizedBox(height: 4),
        FeaturesSnapEdgePicker(value: snapEdge, onChanged: onSnapEdge),
        const SizedBox(height: 12),
        const FeaturesSectionLabel(text: 'Panel Anchor'),
        const SizedBox(height: 4),
        FeaturesPanelAnchorPicker(value: panelAnchor, onChanged: onPanelAnchor),
        const SizedBox(height: 12),
        const FeaturesSectionLabel(text: 'Entrance Animation'),
        const SizedBox(height: 4),
        FeaturesEntrancePicker(
          value: entranceAnimation,
          onChanged: onEntranceAnimation,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Persist Position'),
          subtitle: const Text('Remember bubble position across sessions'),
          value: persistPosition,
          onChanged: onPersistPosition,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
