part of '../survival_overlay.dart';

mixin _SurvivalOverlayLogic on State<_SurvivalOverlayBody> {
  String _lastProxyResult = '';
  int _optimisticDelta = 0;
  int _messageCount = 0;

  int get _displayCounter => widget.state.counter + _optimisticDelta;

  void _increment(int amount) {
    unawaited(widget.kit.dispatch(IncrementAction(amount: amount)));
    setState(() => _optimisticDelta += amount);
  }

  void _sendMessage() {
    _messageCount++;
    final queueCount = widget.kit.queueLength;
    final suffix = queueCount > 0 ? ' (queued: $queueCount)' : '';
    unawaited(
      widget.kit.dispatch(
        MessageAction(
          text: 'Message #$_messageCount from overlay!$suffix',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _getServerTime() async {
    try {
      final result = await widget.kit.callService(
        'time',
        'now',
        fallback: () => {'iso': 'N/A (offline)', 'millis': 0},
      );
      if (result is Map && mounted) {
        setState(() {
          _lastProxyResult = '${result['iso']}';
        });
      }
    } on FloatyProxyException catch (e) {
      if (mounted) {
        setState(() => _lastProxyResult = 'Error: $e');
      }
    }
  }
}
