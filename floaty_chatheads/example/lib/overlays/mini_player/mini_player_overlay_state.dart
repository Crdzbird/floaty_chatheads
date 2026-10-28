part of '../mini_player_overlay.dart';

final class _MiniPlayerOverlayState extends State<MiniPlayerOverlay> {
  String _title = 'No track';
  String _artist = '';
  bool _isPlaying = false;
  late final StreamSubscription<Object?> _dataSub;
  late final StreamSubscription<String> _tapSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is! Map || !mounted) return;
      setState(() {
        if (data['title'] != null) _title = '${data['title']}';
        if (data['artist'] != null) _artist = '${data['artist']}';
        if (data['isPlaying'] is bool) _isPlaying = data['isPlaying'] as bool;
      });
    });
    _tapSub = FloatyOverlay.onTapped.listen((_) => _sendAction('toggle'));
    unawaited(FloatyOverlay.shareData({'action': 'requestState'}));
  }

  void _sendAction(String action) {
    unawaited(FloatyOverlay.shareData({'action': action}));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(8),
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_artist.isNotEmpty)
                  Text(
                    _artist,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                MiniPlayerOverlayControls(
                  isPlaying: _isPlaying,
                  onAction: _sendAction,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => unawaited(FloatyOverlay.closeOverlay()),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_dataSub.cancel());
    unawaited(_tapSub.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
