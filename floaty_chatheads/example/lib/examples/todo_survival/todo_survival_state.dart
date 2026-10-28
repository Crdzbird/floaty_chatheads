part of '../todo_survival_example.dart';

final class _TodoSurvivalExampleState extends State<TodoSurvivalExample>
    with _TodoSurvivalStore, _TodoSurvivalKit, _TodoSurvivalCommands {
  StreamSubscription<String>? _closeSub;

  @override
  void initState() {
    super.initState();

    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });

    _setUpKit();
    unawaited(_restoreAndReconnect());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Survival'),
        actions: todoSurvivalActions(
          chatheadActive: _chatheadActive,
          hasDone: _items.any((t) => t.done),
          onLaunch: () => unawaited(_launch()),
          onAdd: _addFromMain,
          onClearDone: _clearDone,
          onClose: _close,
        ),
      ),
      body: TodoSurvivalBody(
        items: _items,
        log: _log,
        onClearLog: () => setState(_log.clear),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_closeSub?.cancel());
    unawaited(_kit.dispose());
    super.dispose();
  }
}
