part of '../panel_anchor_overlay.dart';

final class _PanelAnchorOverlayState extends State<PanelAnchorOverlay> {
  String _state = 'collapsed';
  String _position = '-';
  StreamSubscription<String>? _expandSub;
  StreamSubscription<String>? _collapseSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _expandSub = FloatyOverlay.onExpanded.listen(
      (_) => unawaited(_report('expanded')),
    );
    _collapseSub = FloatyOverlay.onCollapsed.listen(
      (_) => unawaited(_report('collapsed')),
    );
  }

  Future<String> _origin() async {
    final pos = await FloatyOverlay.getOverlayPosition();
    return '(${pos.x.toStringAsFixed(0)}, ${pos.y.toStringAsFixed(0)})';
  }

  Future<void> _report(String state) async {
    if (state == 'expanded') {
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    final at = await _origin();
    if (mounted) {
      setState(() {
        _state = state;
        _position = at;
      });
    }
    await FloatyOverlay.shareData({
      'playground': state == 'expanded' ? 'Expanded at $at' : 'Collapsed',
    });
  }

  Future<void> _resize(int width, int height) async {
    await FloatyOverlay.resizeContent(width, height);
    final at = await _origin();
    if (mounted) setState(() => _position = at);
    await FloatyOverlay.shareData({
      'playground': 'Resized to ${width}x$height, window at $at',
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
          PanelAnchorStatusBox(state: _state, position: _position),
          const SizedBox(height: 8),
          const Text(
            'Resize (anchored edge stays glued):',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: [
              PanelAnchorResizeChip(
                label: 'S',
                onTap: () => unawaited(_resize(260, 300)),
              ),
              PanelAnchorResizeChip(
                label: 'M',
                onTap: () => unawaited(_resize(320, 420)),
              ),
              PanelAnchorResizeChip(
                label: 'L',
                onTap: () => unawaited(_resize(340, 620)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_expandSub?.cancel());
    unawaited(_collapseSub?.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
