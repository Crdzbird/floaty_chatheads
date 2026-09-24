import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Playground for the `PanelAnchor` feature (v2.1.0): pick where the
/// expanded panel opens relative to the bubble (below / above / auto),
/// combine it with different panel sizes, and watch the native side
/// report back the resolved window position.
class PanelAnchorExample extends StatefulWidget {
  const PanelAnchorExample({super.key});

  @override
  State<PanelAnchorExample> createState() => _PanelAnchorExampleState();
}

class _PanelSize {
  const _PanelSize(this.label, this.width, this.height);

  final String label;
  final int width;
  final int height;
}

class _PanelAnchorExampleState extends State<PanelAnchorExample> {
  static const _sizes = <_PanelSize>[
    _PanelSize('Compact', 260, 300),
    _PanelSize('Card', 320, 420),
    _PanelSize('Tall', 340, 620),
  ];

  PanelAnchor _anchor = PanelAnchor.below;
  _PanelSize _size = _sizes[1];
  final _events = <String>[];
  StreamSubscription<Object?>? _dataSub;

  @override
  void initState() {
    super.initState();
    _dataSub = FloatyChatheads.onData.listen((data) {
      if (data is Map && data['playground'] != null && mounted) {
        setState(() {
          _events.insert(0, '${data['playground']}');
          while (_events.length > 30) {
            _events.removeLast();
          }
        });
      }
    });
  }

  Future<void> _show() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'panelAnchorOverlayMain',
      contentWidth: _size.width,
      contentHeight: _size.height,
      panelAnchor: _anchor,
      entranceAnimation: EntranceAnimation.pop,
      notification: const NotificationConfig(title: 'Panel Anchor Playground'),
    );
    if (mounted) {
      setState(
        () => _events.insert(
          0,
          '🚀 Shown — anchor: ${_anchor.name}, '
          'panel: ${_size.width}x${_size.height}',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Anchor Playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.pink.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'New in 2.1.0: the expanded panel opens below the bubble by '
                'default. Try "above" (on Android the bubble row snaps to '
                'the bottom), or "auto" with the Tall panel and the bubble '
                'dragged near the bottom edge (iOS flips it above). The '
                'panel is always clamped to the screen.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            selected: {_anchor},
            onSelectionChanged: (v) => setState(() => _anchor = v.first),
          ),
          const SizedBox(height: 12),
          const Text(
            'Panel Size',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          SegmentedButton<_PanelSize>(
            segments: [
              for (final s in _sizes)
                ButtonSegment(
                  value: s,
                  label: Text('${s.label}\n${s.width}x${s.height}'),
                ),
            ],
            selected: {_size},
            onSelectionChanged: (v) => setState(() => _size = v.first),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _show,
            icon: const Icon(Icons.bubble_chart),
            label: const Text('Show Chathead'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: FloatyChatheads.expandChatHead,
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Expand'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: FloatyChatheads.collapseChatHead,
                  icon: const Icon(Icons.close_fullscreen),
                  label: const Text('Collapse'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: FloatyChatheads.closeChatHead,
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Events (${_events.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (_events.isNotEmpty)
                TextButton(
                  onPressed: () => setState(_events.clear),
                  child: const Text('Clear'),
                ),
            ],
          ),
          if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Show the chathead, then tap the bubble to expand it.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            for (final event in _events)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(event, style: const TextStyle(fontSize: 13)),
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
