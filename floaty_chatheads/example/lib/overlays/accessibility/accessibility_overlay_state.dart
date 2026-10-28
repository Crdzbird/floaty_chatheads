part of '../accessibility_overlay.dart';

final class _AccessibilityOverlayState extends State<AccessibilityOverlay> {
  int _tapCount = 0;
  StreamSubscription<Object?>? _dataSub;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (mounted) setState(() => _lastMessage = '$data');
    });
  }

  Future<void> _tap() async {
    setState(() => _tapCount++);
    await FloatyOverlay.shareData({'action': 'tap', 'count': _tapCount});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: 'Accessibility test overlay',
        child: AccessibilityOverlayFrame(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Accessibility Test',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  'Tapped $_tapCount times',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (_lastMessage.isNotEmpty)
                AccessibilityOverlayLastMessage(message: _lastMessage),
              const SizedBox(height: 12),
              AccessibilityOverlayTapButton(onTap: () => unawaited(_tap())),
              const SizedBox(height: 8),
              const AccessibilityOverlayCloseButton(),
            ],
          ),
        ),
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
