part of '../panel_anchor_example.dart';

final class _PanelAnchorExampleState extends State<PanelAnchorExample> {
  static const _sizes = <PanelAnchorSize>[
    PanelAnchorSize(label: 'Compact', width: 260, height: 300),
    PanelAnchorSize(label: 'Card', width: 320, height: 420),
    PanelAnchorSize(label: 'Tall', width: 340, height: 620),
  ];

  PanelAnchor _anchor = PanelAnchor.below;
  PanelAnchorSize _size = _sizes[1];
  final _events = <String>[];
  StreamSubscription<Object?>? _dataSub;

  @override
  void initState() {
    super.initState();
    _dataSub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || data['playground'] == null || !mounted) return;
      setState(() {
        _events.insert(0, '${data['playground']}');
        while (_events.length > 30) {
          _events.removeLast();
        }
      });
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
    if (!mounted) return;
    setState(
      () => _events.insert(
        0,
        'Shown: anchor ${_anchor.name}, '
        'panel ${_size.width}x${_size.height}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Anchor Playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PanelAnchorIntroCard(),
          const SizedBox(height: 16),
          PanelAnchorAnchorPicker(
            anchor: _anchor,
            onChanged: (v) => setState(() => _anchor = v),
          ),
          const SizedBox(height: 12),
          PanelAnchorSizePicker(
            sizes: _sizes,
            selected: _size,
            onChanged: (v) => setState(() => _size = v),
          ),
          const SizedBox(height: 16),
          PanelAnchorControls(onShow: () => unawaited(_show())),
          const SizedBox(height: 16),
          PanelAnchorEventLog(
            events: _events,
            onClear: () => setState(_events.clear),
          ),
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
