import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Showcases all advanced features: badge count, programmatic expand/collapse,
/// lifecycle events, snap behavior, entrance animations,
/// and persistent position.
class FeaturesShowcaseExample extends StatefulWidget {
  const FeaturesShowcaseExample({super.key});

  @override
  State<FeaturesShowcaseExample> createState() =>
      _FeaturesShowcaseExampleState();
}

class _FeaturesShowcaseExampleState extends State<FeaturesShowcaseExample> {
  int _badgeCount = 0;
  final _events = <String>[];
  StreamSubscription<Object?>? _dataSub;

  // Configurable options
  SnapEdge _snapEdge = SnapEdge.both;
  EntranceAnimation _entranceAnimation = EntranceAnimation.pop;
  bool _persistPosition = false;
  @override
  void initState() {
    super.initState();
    _dataSub = FloatyChatheads.onData.listen((data) {
      if (mounted) {
        setState(() {
          _events.insert(0, '📨 Data: $data');
          _trimEvents();
        });
      }
    });
  }

  void _trimEvents() {
    while (_events.length > 30) {
      _events.removeLast();
    }
  }

  Future<void> _showChatHead() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'featuresOverlayMain',
      contentWidth: 320,
      contentHeight: 400,
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Features Showcase'),
      snap: SnapConfig(
        edge: _snapEdge,
        margin: -10,
        persistPosition: _persistPosition,
      ),
      entranceAnimation: _entranceAnimation,
    );
    if (mounted) {
      setState(() => _events.insert(0, '🚀 Chathead shown'));
    }
  }

  void _incrementBadge() {
    setState(() => _badgeCount++);
    FloatyChatheads.updateBadge(_badgeCount);
    _events.insert(0, '🔴 Badge → $_badgeCount');
  }

  void _clearBadge() {
    setState(() => _badgeCount = 0);
    FloatyChatheads.updateBadge(0);
    _events.insert(0, '⚪ Badge cleared');
  }

  void _expand() {
    FloatyChatheads.expandChatHead();
    _events.insert(0, '📖 Expand requested');
    if (mounted) setState(() {});
  }

  void _collapse() {
    FloatyChatheads.collapseChatHead();
    _events.insert(0, '📕 Collapse requested');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Show chathead ──────────────────────────────────────
          ElevatedButton.icon(
            onPressed: _showChatHead,
            icon: const Icon(Icons.bubble_chart),
            label: const Text('Show Chathead'),
          ),
          const SizedBox(height: 16),

          // ── Snap Edge ──────────────────────────────────────────
          const Text('Snap Edge',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SegmentedButton<SnapEdge>(
            segments: const [
              ButtonSegment(value: SnapEdge.both, label: Text('Both')),
              ButtonSegment(value: SnapEdge.left, label: Text('Left')),
              ButtonSegment(value: SnapEdge.right, label: Text('Right')),
              ButtonSegment(value: SnapEdge.none, label: Text('None')),
            ],
            selected: {_snapEdge},
            onSelectionChanged: (v) => setState(() => _snapEdge = v.first),
          ),
          const SizedBox(height: 12),

          // ── Entrance Animation ─────────────────────────────────
          const Text('Entrance Animation',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SegmentedButton<EntranceAnimation>(
            segments: const [
              ButtonSegment(
                  value: EntranceAnimation.none, label: Text('None')),
              ButtonSegment(
                  value: EntranceAnimation.pop, label: Text('Pop')),
              ButtonSegment(
                  value: EntranceAnimation.slideFromEdge,
                  label: Text('Slide')),
              ButtonSegment(
                  value: EntranceAnimation.fade, label: Text('Fade')),
            ],
            selected: {_entranceAnimation},
            onSelectionChanged: (v) =>
                setState(() => _entranceAnimation = v.first),
          ),
          const SizedBox(height: 12),

          // ── Persist Position ────────────────────────────────────
          SwitchListTile(
            title: const Text('Persist Position'),
            subtitle:
                const Text('Remember bubble position across sessions'),
            value: _persistPosition,
            onChanged: (v) => setState(() => _persistPosition = v),
            contentPadding: EdgeInsets.zero,
          ),

          // ── Badge controls ─────────────────────────────────────
          const Text('Badge Count',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _incrementBadge,
                  icon: const Icon(Icons.add_circle),
                  label: Text('Badge +1  ($_badgeCount)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _clearBadge,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Expand / Collapse ──────────────────────────────────
          const Text('Programmatic Control',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _expand,
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Expand'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _collapse,
                  icon: const Icon(Icons.close_fullscreen),
                  label: const Text('Collapse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => FloatyChatheads.closeChatHead(),
            icon: const Icon(Icons.close),
            label: const Text('Close Chathead'),
          ),
          const Divider(height: 24),

          // ── Event Log ──────────────────────────────────────────
          Row(
            children: [
              Text(
                'Event Log (${_events.length})',
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
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Show the chathead, then use the controls above.\n'
                'Lifecycle events will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...List.generate(
              _events.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  _events[i],
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    FloatyChatheads.closeChatHead();
    super.dispose();
  }
}
