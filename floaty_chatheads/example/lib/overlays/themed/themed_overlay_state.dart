part of '../themed_overlay.dart';

final class _ThemedOverlayState extends State<ThemedOverlay> {
  OverlayColorPalette? _palette;
  StreamSubscription<OverlayColorPalette>? _paletteSub;
  StreamSubscription<Object?>? _dataSub;
  String _lastMessage = 'Waiting for data...';

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _palette = FloatyOverlay.palette;
    _paletteSub = FloatyOverlay.onPaletteChanged.listen((p) {
      if (mounted) setState(() => _palette = p);
    });
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (mounted) setState(() => _lastMessage = '$data');
    });
  }

  void _sendToMain() {
    unawaited(
      FloatyOverlay.shareData({
        'from': 'themed_overlay',
        'palette_received': _palette != null,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _palette.surfaceOrDefault,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _palette.primaryOrDefault.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemedOverlayHeader(palette: _palette),
              ThemedOverlayBody(
                palette: _palette,
                lastMessage: _lastMessage,
                onSend: _sendToMain,
                onClose: () => unawaited(FloatyOverlay.closeOverlay()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_paletteSub?.cancel());
    unawaited(_dataSub?.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
