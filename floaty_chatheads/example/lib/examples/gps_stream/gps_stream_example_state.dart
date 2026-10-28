part of '../gps_stream_example.dart';

final class _GpsStreamExampleState extends State<GpsStreamExample>
    with _GpsSimulation {
  bool _chatheadActive = false;
  StreamSubscription<String>? _closeSub;

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (!mounted) return;
      setState(() => _chatheadActive = false);
      _stopSimulation();
    });

    _gpsStream = FloatyProxyStream(GpsCoord.streamKey);
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'gpsStreamOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'GPS Stream'),
      snap: const SnapConfig(edge: SnapEdge.both),
      contentWidth: 240,
      contentHeight: 220,
    );
    setState(() => _chatheadActive = true);
    _startSimulation();
  }

  void _close() {
    unawaited(FloatyChatheads.closeChatHead());
    _stopSimulation();
    setState(() {
      _chatheadActive = false;
      _log.insert(0, '[closed]');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Proxy Stream'),
        actions: [
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close overlay',
              onPressed: _close,
            ),
        ],
      ),
      floatingActionButton: !_chatheadActive
          ? FloatingActionButton.extended(
              onPressed: () => unawaited(_launch()),
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Launch GPS'),
            )
          : null,
      body: Column(
        children: [
          const GpsStreamIntro(),
          GpsPositionRow(
            lat: _lat,
            lng: _lng,
            active: _chatheadActive,
            updateCount: _updateCount,
          ),
          const Divider(height: 1),
          GpsLogHeader(count: _log.length, onClear: () => setState(_log.clear)),
          Expanded(child: GpsLogList(entries: _log)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_closeSub?.cancel());
    _stopSimulation();
    unawaited(_gpsStream.dispose());
    super.dispose();
  }
}
