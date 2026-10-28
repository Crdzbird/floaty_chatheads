part of '../survival_overlay.dart';

final class _SurvivalOverlayBodyState extends State<_SurvivalOverlayBody>
    with _SurvivalOverlayLogic {
  @override
  void didUpdateWidget(_SurvivalOverlayBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.counter != widget.state.counter) {
      _optimisticDelta = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueCount = widget.kit.queueLength;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SurvivalConnectionBanner(connected: widget.connected),
              SurvivalCounterDisplay(
                value: _displayCounter,
                label: widget.state.label,
                connected: widget.connected,
              ),
              SurvivalCounterButtons(onIncrement: _increment),
              const SizedBox(height: 8),
              if (queueCount > 0) SurvivalQueueBadge(count: queueCount),
              const SizedBox(height: 8),
              SurvivalServerTimeButton(
                result: _lastProxyResult,
                onTap: () => unawaited(_getServerTime()),
              ),
              const SizedBox(height: 8),
              SurvivalOverlayFooter(onSendMessage: _sendMessage),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
