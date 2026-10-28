part of '../survival_example.dart';

mixin _SurvivalStore on State<SurvivalExample> {
  static const _counterKey = 'survival_counter';
  static const _maxLogEntries = 50;

  bool _chatheadActive = false;
  int _counter = 0;
  bool _counterRestored = false;
  final _bufferedActions = <IncrementAction>[];
  final _log = <String>[];

  late final FloatyHostKit<SurvivalState> _kit;

  void _addLog(String entry) {
    _log.insert(0, entry);
    if (_log.length > _maxLogEntries) _log.removeLast();
  }

  Future<void> _persistCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
  }

  Future<void> _restoreCounter() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt(_counterKey) ?? 0;
  }
}
