import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../models/todo_actions.dart';

/// Overlay that demonstrates survival with a **todo list**.
///
/// - **Connection banner** — green when connected, red when the main
///   app is killed.
/// - **Add / toggle / remove** — dispatch typed actions via the kit.
///   When disconnected, actions are queued (badge shows count).
/// - **Stats proxy** — calls a proxy service. Returns a fallback
///   when disconnected instead of timing out.
/// - **State sync** — receives the full task list from the main app.
class TodoSurvivalOverlay extends StatelessWidget {
  const TodoSurvivalOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayScope<TodoState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: TodoState.fromJson,
      initialState: TodoState(),
      builder: (context, kit, state, connected) {
        return _TodoOverlayContent(
          kit: kit,
          state: state,
          connected: connected,
        );
      },
    );
  }
}

class _TodoOverlayContent extends StatefulWidget {
  const _TodoOverlayContent({
    required this.kit,
    required this.state,
    required this.connected,
  });

  final FloatyOverlayKit<TodoState> kit;
  final TodoState state;
  final bool connected;

  @override
  State<_TodoOverlayContent> createState() => _TodoOverlayContentState();
}

class _TodoOverlayContentState extends State<_TodoOverlayContent> {
  String _statsResult = '';

  // Optimistic local copy of items — kept in sync with state updates
  // from the main app, but also updated locally for instant feedback.
  late List<TodoItem> _localItems;
  int _addCount = 0;

  @override
  void initState() {
    super.initState();
    _localItems = List.of(widget.state.items);
  }

  @override
  void didUpdateWidget(_TodoOverlayContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the main app pushes a new state, replace local copy.
    if (oldWidget.state != widget.state) {
      _localItems = List.of(widget.state.items);
    }
  }

  void _addTask() {
    _addCount++;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final title = 'Overlay task #$_addCount';
    widget.kit.dispatch(AddTodoAction(id: id, title: title));
    // Optimistic local update.
    setState(() {
      _localItems.add(TodoItem(id: id, title: title));
    });
  }

  void _toggleTask(TodoItem item) {
    widget.kit.dispatch(ToggleTodoAction(id: item.id));
    setState(() {
      final idx = _localItems.indexWhere((t) => t.id == item.id);
      if (idx != -1) {
        _localItems[idx] = _localItems[idx].copyWith(done: !item.done);
      }
    });
  }

  void _removeTask(TodoItem item) {
    widget.kit.dispatch(RemoveTodoAction(id: item.id));
    setState(() {
      _localItems.removeWhere((t) => t.id == item.id);
    });
  }

  Future<void> _getStats() async {
    try {
      final result = await widget.kit.callService(
        'stats',
        'summary',
        fallback: () => {'total': '?', 'done': '?', 'pending': '?'},
      );
      if (result is Map && mounted) {
        setState(() {
          _statsResult =
              '${result['total']} total, ${result['done']} done, '
              '${result['pending']} pending';
        });
      }
    } on FloatyProxyException catch (e) {
      if (mounted) {
        setState(() => _statsResult = 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueCount = widget.kit.queueLength;
    final done = _localItems.where((t) => t.done).length;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Connection banner ──
              _ConnectionBanner(connected: widget.connected),

              // ── Header with count ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 18,
                      color: widget.connected ? Colors.teal : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_localItems.length} tasks ($done done)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.connected
                            ? Colors.teal.shade700
                            : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _addTask,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 12, color: Colors.white),
                            SizedBox(width: 2),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Task list ──
              if (_localItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No tasks yet.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _localItems.length,
                    itemBuilder: (_, i) {
                      final item = _localItems[i];
                      return _TaskRow(
                        item: item,
                        onToggle: () => _toggleTask(item),
                        onRemove: () => _removeTask(item),
                      );
                    },
                  ),
                ),

              // ── Queue badge ──
              if (queueCount > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.queue,
                        size: 12,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$queueCount queued',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 6),

              // ── Stats proxy ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: _getStats,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 12,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Get Stats (proxy)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (_statsResult.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _statsResult,
                            style: TextStyle(
                              fontSize: 8,
                              color: _statsResult.contains('?')
                                  ? Colors.red.shade400
                                  : Colors.blue.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ── Close button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: connected ? Colors.green : Colors.red.shade700,
      child: Row(
        children: [
          Icon(
            connected ? Icons.link : Icons.link_off,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              connected ? 'Connected' : 'Disconnected',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          if (!connected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'OFFLINE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (connected)
            GestureDetector(
              onTap: FloatyOverlay.closeOverlay,
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 13,
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.item,
    required this.onToggle,
    required this.onRemove,
  });

  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              item.done
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 16,
              color: item.done ? Colors.green : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 11,
                decoration: item.done ? TextDecoration.lineThrough : null,
                color: item.done ? Colors.grey : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
