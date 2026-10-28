part of '../todo_survival_example.dart';

mixin _TodoSurvivalStore on State<TodoSurvivalExample> {
  static const _storageKey = 'todo_survival_items';
  static const _maxLogEntries = 50;

  List<TodoItem> _items = [];
  bool _stateRestored = false;
  final _bufferedActions = <FloatyAction>[];
  final _log = <String>[];

  void _addLog(String entry) {
    _log.insert(0, entry);
    if (_log.length > _maxLogEntries) _log.removeLast();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _items = decoded
        .whereType<Map<String, dynamic>>()
        .map(TodoItem.fromJson)
        .toList();
  }

  void _applyAction(FloatyAction action, {bool log = true}) {
    switch (action) {
      case AddTodoAction():
        _items.add(TodoItem(id: action.id, title: action.title));
        if (log) _addLog('[+] "${action.title}"');
      case ToggleTodoAction():
        _applyToggle(action.id, log: log);
      case RemoveTodoAction():
        _applyRemove(action.id, log: log);
    }
  }

  void _applyToggle(String id, {required bool log}) {
    final idx = _items.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final item = _items[idx];
    _items[idx] = item.copyWith(done: !item.done);
    if (!log) return;
    final status = _items[idx].done ? 'done' : 'undone';
    _addLog('[~] "${item.title}": $status');
  }

  void _applyRemove(String id, {required bool log}) {
    final idx = _items.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final title = _items[idx].title;
    _items.removeAt(idx);
    if (log) _addLog('[-] "$title" removed');
  }
}
