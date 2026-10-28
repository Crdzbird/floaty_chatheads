part of '../todo_survival_example.dart';

mixin _TodoSurvivalCommands
    on State<TodoSurvivalExample>, _TodoSurvivalStore, _TodoSurvivalKit {
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

    await _kit.setState(
      TodoState(
        items: _items,
        label: 'Connected',
      ),
    );
  }

  void _close() {
    unawaited(FloatyChatheads.closeChatHead());
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
}
