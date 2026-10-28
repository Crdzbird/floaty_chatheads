part of 'todo_survival_overlay_content.dart';

final class _TodoSurvivalOverlayContentState
    extends State<TodoSurvivalOverlayContent>
    with _TodoSurvivalOverlayTasks {
  String _statsResult = '';

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
              TodoSurvivalOverlayBanner(connected: widget.connected),
              TodoSurvivalOverlayHeader(
                taskCount: _localItems.length,
                doneCount: done,
                connected: widget.connected,
                onAdd: _addTask,
              ),
              const SizedBox(height: 6),
              TodoSurvivalOverlayTaskList(
                items: _localItems,
                onToggle: _toggleTask,
                onRemove: _removeTask,
              ),
              if (queueCount > 0)
                TodoSurvivalOverlayQueueBadge(queueCount: queueCount),
              const SizedBox(height: 6),
              TodoSurvivalOverlayStatsButton(
                result: _statsResult,
                onTap: () => unawaited(_getStats()),
              ),
              const SizedBox(height: 6),
              const TodoSurvivalOverlayCloseRow(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
