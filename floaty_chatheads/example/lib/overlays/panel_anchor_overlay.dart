import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Overlay side of the Panel Anchor Playground.
///
/// Reports every expand/collapse to the main app together with the
/// window position the native side resolved, and offers resize buttons
/// so the anchored-resize behavior can be tested live (the panel edge
/// facing the bubble must stay glued while the panel grows/shrinks).
class PanelAnchorOverlay extends StatefulWidget {
  const PanelAnchorOverlay({super.key});

  @override
  State<PanelAnchorOverlay> createState() => _PanelAnchorOverlayState();
}

class _PanelAnchorOverlayState extends State<PanelAnchorOverlay> {
  String _state = 'collapsed';
  String _position = '—';
  StreamSubscription<String>? _expandSub;
  StreamSubscription<String>? _collapseSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _expandSub = FloatyOverlay.onExpanded.listen((_) => _report('expanded'));
    _collapseSub =
        FloatyOverlay.onCollapsed.listen((_) => _report('collapsed'));
  }

  Future<void> _report(String state) async {
    if (state == 'expanded') {
      // The expand notification fires while the bubbles are still
      // spring-animating into the row — let them settle before sampling.
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    final pos = await FloatyOverlay.getOverlayPosition();
    final at = '(${pos.x.toStringAsFixed(0)}, ${pos.y.toStringAsFixed(0)})';
    if (mounted) {
      setState(() {
        _state = state;
        _position = at;
      });
    }
    await FloatyOverlay.shareData({
      'playground': state == 'expanded' ? '📖 Expanded at $at' : '📕 Collapsed',
    });
  }

  Future<void> _resize(int width, int height) async {
    await FloatyOverlay.resizeContent(width, height);
    final pos = await FloatyOverlay.getOverlayPosition();
    final at = '(${pos.x.toStringAsFixed(0)}, ${pos.y.toStringAsFixed(0)})';
    if (mounted) setState(() => _position = at);
    await FloatyOverlay.shareData({
      'playground': '📐 Resized to ${width}x$height — window at $at',
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatySimplePanel(
      title: 'Anchor Playground',
      backgroundColor: Colors.pink.shade700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'State: $_state\nWindow origin: $_position',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resize (anchored edge stays glued):',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: [
              _ResizeChip(label: 'S', onTap: () => _resize(260, 300)),
              _ResizeChip(label: 'M', onTap: () => _resize(320, 420)),
              _ResizeChip(label: 'L', onTap: () => _resize(340, 620)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _expandSub?.cancel();
    _collapseSub?.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

class _ResizeChip extends StatelessWidget {
  const _ResizeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
    );
  }
}
