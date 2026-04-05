import 'dart:async';
import 'dart:convert';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_actions.dart';
import '../utils.dart';

/// Demonstrates overlay survival with a **todo list** instead of a counter.
///
/// 1. **Connection state** — the overlay shows a live connected /
///    disconnected banner via `FloatyConnectionState`.
/// 2. **Action queueing** — add / toggle / remove actions dispatched
///    while disconnected are queued and flushed when the app reconnects.
/// 3. **Proxy fallback** — proxy calls return a fallback value instead
///    of timing out when the main app is unavailable.
///
/// **How to test:**
///
///  1. Tap "Launch Overlay" to show the chathead.
///  2. See the green "Connected" banner in the overlay.
///  3. Force-stop the app from recent apps.
///  4. The overlay stays visible — banner turns red "Disconnected".
///  5. Add / toggle / remove tasks in the overlay — actions are queued.
///  6. Re-open the app — banner turns green, queued actions flush into
///     the log below.
class TodoSurvivalExample extends StatefulWidget {
  const TodoSurvivalExample({super.key});

  @override
  State<TodoSurvivalExample> createState() => _TodoSurvivalExampleState();
}

class _TodoSurvivalExampleState extends State<TodoSurvivalExample> {
  static const _storageKey = 'todo_survival_items';

  bool _chatheadActive = false;
  StreamSubscription<String>? _closeSub;
  List<TodoItem> _items = [];
  bool _stateRestored = false;
  final _bufferedActions = <FloatyAction>[];
  final _log = <String>[];
  static const _maxLogEntries = 50;

  late final FloatyHostKit<TodoState> _kit;

  void _addLog(String entry) {
    _log.insert(0, entry);
    if (_log.length > _maxLogEntries) _log.removeLast();
  }

  // ── Persistence ─────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _items = decoded
          .whereType<Map<String, dynamic>>()
          .map(TodoItem.fromJson)
          .toList();
    }
  }

  // ── Action application ──────────────────────────────────────────────

  void _applyAction(FloatyAction action, {bool log = true}) {
    if (action is AddTodoAction) {
      _items.add(TodoItem(id: action.id, title: action.title));
      if (log) _addLog('[+] "${action.title}"');
    } else if (action is ToggleTodoAction) {
      final idx = _items.indexWhere((t) => t.id == action.id);
      if (idx != -1) {
        final item = _items[idx];
        _items[idx] = item.copyWith(done: !item.done);
        if (log) {
          final status = _items[idx].done ? 'done' : 'undone';
          _addLog('[~] "${item.title}" -> $status');
        }
      }
    } else if (action is RemoveTodoAction) {
      final idx = _items.indexWhere((t) => t.id == action.id);
      if (idx != -1) {
        final title = _items[idx].title;
        _items.removeAt(idx);
        if (log) _addLog('[-] "$title" removed');
      }
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });

    _kit = FloatyHostKit<TodoState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: TodoState.fromJson,
      initialState: TodoState(),
    );

    _kit.onAction<AddTodoAction>(
      'add_todo',
      fromJson: AddTodoAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        if (!_stateRestored) {
          _bufferedActions.add(action);
          return;
        }
        setState(() => _applyAction(action));
        unawaited(_persist());
        _syncToOverlay('Added');
      },
    );

    _kit.onAction<ToggleTodoAction>(
      'toggle_todo',
      fromJson: ToggleTodoAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        if (!_stateRestored) {
          _bufferedActions.add(action);
          return;
        }
        setState(() => _applyAction(action));
        unawaited(_persist());
        _syncToOverlay('Toggled');
      },
    );

    _kit.onAction<RemoveTodoAction>(
      'remove_todo',
      fromJson: RemoveTodoAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        if (!_stateRestored) {
          _bufferedActions.add(action);
          return;
        }
        setState(() => _applyAction(action));
        unawaited(_persist());
        _syncToOverlay('Removed');
      },
    );

    _kit.registerService('stats', (method, params) {
      if (method == 'summary') {
        final done = _items.where((t) => t.done).length;
        return {
          'total': _items.length,
          'done': done,
          'pending': _items.length - done,
        };
      }
      return null;
    });

    _restoreAndReconnect();
  }

  void _syncToOverlay(String label) {
    unawaited(
      _kit.setState(TodoState(items: _items, label: label)),
    );
  }

  Future<void> _restoreAndReconnect() async {
    await _restore();
    _stateRestored = true;

    // Replay any actions that arrived (via queue flush) before the
    // persisted state was restored.
    final hadBuffered = _bufferedActions.isNotEmpty;
    _bufferedActions.forEach(_applyAction);
    _bufferedActions.clear();
    if (hadBuffered) unawaited(_persist());

    if (!mounted) return;

    final active = await FloatyChatheads.isActive();
    if (!mounted) return;

    if (active) {
      setState(() {
        _chatheadActive = true;
        _addLog('[reconnected] ${_items.length} tasks restored');
      });
      await _kit.setState(TodoState(
        items: _items,
        label: 'Reconnected',
      ));
    } else {
      if (_items.isNotEmpty) setState(() {});
    }
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'todoSurvivalOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Todo Survival'),
      snap: const SnapConfig(edge: SnapEdge.both),
      contentWidth: 260,
      contentHeight: 380,
      entranceAnimation: EntranceAnimation.pop,
      persistOnAppClose: true,
    );
    setState(() => _chatheadActive = true);

    await _kit.setState(TodoState(
      items: _items,
      label: 'Connected',
    ));
  }

  void _close() {
    FloatyChatheads.closeChatHead();
    setState(() {
      _chatheadActive = false;
      _addLog('[closed] overlay dismissed');
    });
  }

  void _addFromMain() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final title = 'Task #${_items.length + 1}';
    setState(() {
      _items.add(TodoItem(id: id, title: title));
      _addLog('[main +] "$title"');
    });
    unawaited(_persist());
    _syncToOverlay('Main added');
  }

  void _clearDone() {
    final removed = _items.where((t) => t.done).length;
    setState(() {
      _items.removeWhere((t) => t.done);
      _addLog('[main] cleared $removed done tasks');
    });
    unawaited(_persist());
    _syncToOverlay('Cleared done');
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final done = _items.where((t) => t.done).length;
    final pending = _items.length - done;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Survival'),
        actions: [
          if (!_chatheadActive)
            IconButton(
              icon: const Icon(Icons.rocket_launch),
              tooltip: 'Launch overlay',
              onPressed: _launch,
            ),
          if (_chatheadActive) ...[
            IconButton(
              icon: const Icon(Icons.add_task),
              tooltip: 'Add from main',
              onPressed: _addFromMain,
            ),
            if (done > 0)
              IconButton(
                icon: const Icon(Icons.cleaning_services),
                tooltip: 'Clear done',
                onPressed: _clearDone,
              ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close overlay',
              onPressed: _close,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to test:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1. Launch the overlay\n'
                  '2. Add tasks from the overlay\n'
                  '3. Force-stop this app from recents\n'
                  '4. Add / toggle / remove tasks (queued)\n'
                  '5. Re-open app — actions flush here',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Stats bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _StatChip(
                  label: 'Total',
                  value: '${_items.length}',
                  color: Colors.teal,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Pending',
                  value: '$pending',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Done',
                  value: '$done',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Task list
          if (_items.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return Row(
                    children: [
                      Icon(
                        item.done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: item.done ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            decoration: item.done
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.done ? Colors.grey : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const Divider(height: 1),

          // Log header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  'Action Log (${_log.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_log.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_log.clear),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: _log.isEmpty
                ? const Center(
                    child: Text(
                      'Actions from the overlay will appear here.\n'
                      'Try killing the app and managing\n'
                      'tasks from the overlay!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _log[i],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeSub?.cancel();
    _kit.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
