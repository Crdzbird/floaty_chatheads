part of '../todo_survival_example.dart';

mixin _TodoSurvivalKit on State<TodoSurvivalExample>, _TodoSurvivalStore {
  bool _chatheadActive = false;
  late final FloatyHostKit<TodoState> _kit;

  void _setUpKit() {
    _kit = FloatyHostKit<TodoState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: TodoState.fromJson,
      initialState: TodoState(),
    );
    _kit.onAction(AddTodoAction.key, (a) => _handleAction(a, 'Added'));
    _kit.onAction(ToggleTodoAction.key, (a) => _handleAction(a, 'Toggled'));
    _kit.onAction(RemoveTodoAction.key, (a) => _handleAction(a, 'Removed'));
    _kit.registerService('stats', (method, params) {
      if (method != 'summary') return null;
      final done = _items.where((t) => t.done).length;
      return {
        'total': _items.length,
        'done': done,
        'pending': _items.length - done,
      };
    });
  }

  void _handleAction(FloatyAction action, String label) {
    if (!mounted) return;
    if (!_stateRestored) {
      _bufferedActions.add(action);
      return;
    }
    setState(() => _applyAction(action));
    unawaited(_persist());
    _syncToOverlay(label);
  }

  void _syncToOverlay(String label) {
    unawaited(
      _kit.setState(TodoState(items: _items, label: label)),
    );
  }

  Future<void> _restoreAndReconnect() async {
    await _restore();
    _stateRestored = true;

    final hadBuffered = _bufferedActions.isNotEmpty;
    _bufferedActions.forEach(_applyAction);
    _bufferedActions.clear();
    if (hadBuffered) unawaited(_persist());

    if (!mounted) return;

    final active = await FloatyChatheads.isActive();
    if (!mounted) return;

    if (!active) {
      if (_items.isNotEmpty) setState(() {});
      return;
    }
    setState(() {
      _chatheadActive = true;
      _addLog('[reconnected] ${_items.length} tasks restored');
    });
    await _kit.setState(
      TodoState(
        items: _items,
        label: 'Reconnected',
      ),
    );
  }
}
