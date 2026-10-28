part of 'overlay_content.dart';

final class _OverlayContentState extends State<OverlayContent> {
  String _lastReceived = 'No data yet';
  int _sendCount = 0;
  StreamSubscription<Object?>? _dataSub;

  @override
  void initState() {
    super.initState();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (!mounted) return;
      setState(() => _lastReceived = '$data');
    });
  }

  Future<void> _sendToMain() async {
    _sendCount++;
    await FloatyOverlay.shareData({
      'message': 'Hello #$_sendCount',
      'from': 'overlay',
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatySimplePanel(
      title: 'Overlay',
      backgroundColor: Colors.teal.shade700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LastReceivedBox(text: _lastReceived),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => unawaited(_sendToMain()),
            child: const Text('Send to Main'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_dataSub?.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
