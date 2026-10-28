part of 'todo_survival_overlay_content.dart';

mixin _TodoSurvivalOverlayTasks on State<TodoSurvivalOverlayContent> {
  late List<TodoItem> _localItems;
  int _addCount = 0;

  @override
  void initState() {
    super.initState();
    _localItems = List.of(widget.state.items);
  }

  @override
  void didUpdateWidget(TodoSurvivalOverlayContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _localItems = List.of(widget.state.items);
    }
  }

  void _addTask() {
    _addCount++;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final title = 'Overlay task #$_addCount';
    unawaited(widget.kit.dispatch(AddTodoAction(id: id, title: title)));
    setState(() {
      _localItems.add(TodoItem(id: id, title: title));
    });
  }

  void _toggleTask(TodoItem item) {
    unawaited(widget.kit.dispatch(ToggleTodoAction(id: item.id)));
    setState(() {
      final idx = _localItems.indexWhere((t) => t.id == item.id);
      if (idx != -1) {
        _localItems[idx] = _localItems[idx].copyWith(done: !item.done);
      }
    });
  }

  void _removeTask(TodoItem item) {
    unawaited(widget.kit.dispatch(RemoveTodoAction(id: item.id)));
    setState(() {
      _localItems.removeWhere((t) => t.id == item.id);
    });
  }
}
