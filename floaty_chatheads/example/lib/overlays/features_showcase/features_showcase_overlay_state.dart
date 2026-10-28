part of '../features_showcase_overlay.dart';

final class _FeaturesShowcaseOverlayState
    extends State<FeaturesShowcaseOverlay> {
  int _badgeCount = 0;
  final _events = <String>[];
  final _subs = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    debugPrint(
      'FeaturesShowcaseOverlay: initState() called, overlay is running',
    );
    FloatyOverlay.setUp();
    debugPrint('FeaturesShowcaseOverlay: FloatyOverlay.setUp() complete');
    _subs.addAll([
      FloatyOverlay.onTapped.listen((id) => _addEvent('Tapped: $id')),
      FloatyOverlay.onExpanded.listen((id) => _addEvent('Expanded: $id')),
      FloatyOverlay.onCollapsed.listen((id) => _addEvent('Collapsed: $id')),
      FloatyOverlay.onDragStart.listen(
        (e) => _addEvent('Drag start: (${e.x.toInt()}, ${e.y.toInt()})'),
      ),
      FloatyOverlay.onDragEnd.listen(
        (e) => _addEvent('Drag end: (${e.x.toInt()}, ${e.y.toInt()})'),
      ),
    ]);
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
    unawaited(FloatyOverlay.updateBadge(_badgeCount));
  }

  void _clearBadge() {
    setState(() => _badgeCount = 0);
    unawaited(FloatyOverlay.updateBadge(0));
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
              FeaturesOverlayHeader(
                onClose: () => unawaited(FloatyOverlay.closeOverlay()),
              ),
              FeaturesOverlayBadgeRow(
                count: _badgeCount,
                onIncrement: _incrementBadge,
                onClear: _clearBadge,
              ),
              FeaturesOverlayEventLog(events: _events),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    FloatyOverlay.dispose();
    super.dispose();
  }
}
