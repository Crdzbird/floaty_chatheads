import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Overlay for the features showcase. Displays lifecycle events and
/// lets the user control badge count from within the overlay.
class FeaturesShowcaseOverlay extends StatefulWidget {
  const FeaturesShowcaseOverlay({super.key});

  @override
  State<FeaturesShowcaseOverlay> createState() =>
      _FeaturesShowcaseOverlayState();
}

class _FeaturesShowcaseOverlayState extends State<FeaturesShowcaseOverlay> {
  int _badgeCount = 0;
  final _events = <String>[];
  StreamSubscription<String>? _tapSub;
  StreamSubscription<String>? _expandSub;
  StreamSubscription<String>? _collapseSub;
  StreamSubscription<ChatHeadDragEvent>? _dragStartSub;
  StreamSubscription<ChatHeadDragEvent>? _dragEndSub;

  @override
  void initState() {
    super.initState();
    debugPrint('FeaturesShowcaseOverlay: initState() called — overlay is running');
    FloatyOverlay.setUp();
    debugPrint('FeaturesShowcaseOverlay: FloatyOverlay.setUp() complete');

    _tapSub = FloatyOverlay.onTapped.listen((id) {
      _addEvent('👆 Tapped: $id');
    });
    _expandSub = FloatyOverlay.onExpanded.listen((id) {
      _addEvent('📖 Expanded: $id');
    });
    _collapseSub = FloatyOverlay.onCollapsed.listen((id) {
      _addEvent('📕 Collapsed: $id');
    });
    _dragStartSub = FloatyOverlay.onDragStart.listen((e) {
      _addEvent('🟢 Drag start: (${e.x.toInt()}, ${e.y.toInt()})');
    });
    _dragEndSub = FloatyOverlay.onDragEnd.listen((e) {
      _addEvent('🔴 Drag end: (${e.x.toInt()}, ${e.y.toInt()})');
    });
  }

  void _addEvent(String event) {
    if (!mounted) return;
    setState(() {
      _events.insert(0, event);
      if (_events.length > 20) _events.removeLast();
    });
  }

  void _incrementBadge() {
    setState(() => _badgeCount++);
    FloatyOverlay.updateBadge(_badgeCount);
  }

  void _clearBadge() {
    setState(() => _badgeCount = 0);
    FloatyOverlay.updateBadge(0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF16213E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Features Showcase',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: const Icon(Icons.close, color: Colors.white54, size: 18),
                    ),
                  ],
                ),
              ),
              // Badge controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _incrementBadge,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔴 Badge +1 ($_badgeCount)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _clearBadge,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Events log
              Container(
                height: 180,
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _events.isEmpty
                    ? const Center(
                        child: Text(
                          'Lifecycle events\nwill appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white30, fontSize: 11),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            _events[i],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tapSub?.cancel();
    _expandSub?.cancel();
    _collapseSub?.cancel();
    _dragStartSub?.cancel();
    _dragEndSub?.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
