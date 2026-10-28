part of '../features_showcase_example.dart';

final class _FeaturesShowcaseExampleState extends State<FeaturesShowcaseExample>
    with _FeaturesShowcaseLogic {
  StreamSubscription<Object?>? _dataSub;

  @override
  void initState() {
    super.initState();
    _dataSub = FloatyChatheads.onData.listen(_onData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: () => unawaited(_showChatHead()),
            icon: const Icon(Icons.bubble_chart),
            label: const Text('Show Chathead'),
          ),
          const SizedBox(height: 16),
          FeaturesOptionsPanel(
            snapEdge: _snapEdge,
            panelAnchor: _panelAnchor,
            entranceAnimation: _entranceAnimation,
            persistPosition: _persistPosition,
            onSnapEdge: (v) => setState(() => _snapEdge = v),
            onPanelAnchor: (v) => setState(() => _panelAnchor = v),
            onEntranceAnimation: (v) => setState(() => _entranceAnimation = v),
            onPersistPosition: (v) => setState(() => _persistPosition = v),
          ),
          const FeaturesSectionLabel(text: 'Badge Count'),
          const SizedBox(height: 4),
          FeaturesBadgeRow(
            count: _badgeCount,
            onIncrement: _incrementBadge,
            onClear: _clearBadge,
          ),
          const SizedBox(height: 12),
          const FeaturesSectionLabel(text: 'Programmatic Control'),
          const SizedBox(height: 4),
          FeaturesExpandRow(onExpand: _expand, onCollapse: _collapse),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => unawaited(FloatyChatheads.closeChatHead()),
            icon: const Icon(Icons.close),
            label: const Text('Close Chathead'),
          ),
          const Divider(height: 24),
          FeaturesEventLogHeader(
            count: _events.length,
            onClear: () => setState(_events.clear),
          ),
          FeaturesEventLog(events: _events),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_dataSub?.cancel());
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
