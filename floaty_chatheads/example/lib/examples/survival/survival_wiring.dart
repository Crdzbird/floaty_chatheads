part of '../survival_example.dart';

mixin _SurvivalWiring on _SurvivalStore {
  void _wireKit() {
    _kit = FloatyHostKit<SurvivalState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: SurvivalState.fromJson,
      initialState: SurvivalState(),
    );
    _kit.onAction(IncrementAction.key, _onIncrement);
    _kit.onAction(MessageAction.key, (action) {
      if (!mounted) return;
      setState(() => _addLog(action.text));
    });
    _kit.registerService('time', (method, params) {
      if (method != 'now') return null;
      final now = DateTime.now();
      return {
        'iso': now.toIso8601String(),
        'millis': now.millisecondsSinceEpoch,
      };
    });
  }

  void _onIncrement(IncrementAction action) {
    if (!mounted) return;
    if (!_counterRestored) {
      _bufferedActions.add(action);
      return;
    }
    setState(() {
      _counter += action.amount;
      _addLog('[+${action.amount}] counter = $_counter');
    });
    unawaited(_persistCounter());
    unawaited(
      _kit.setState(
        SurvivalState(counter: _counter, label: 'Updated from main'),
      ),
    );
  }

  Future<void> _restoreAndReconnect() async {
    await _restoreCounter();
    _counterRestored = true;
    final hadBuffered = _bufferedActions.isNotEmpty;
    for (final action in _bufferedActions) {
      _counter += action.amount;
      _addLog('[queued +${action.amount}] counter = $_counter');
    }
    _bufferedActions.clear();
    if (hadBuffered) unawaited(_persistCounter());
    if (!mounted) return;
    final active = await FloatyChatheads.isActive();
    if (!mounted) return;
    if (!active) {
      if (_counter != 0) setState(() {});
      return;
    }
    setState(() {
      _chatheadActive = true;
      _addLog('[reconnected] counter = $_counter');
    });
    await _kit.setState(
      SurvivalState(counter: _counter, label: 'Reconnected'),
    );
  }
}
