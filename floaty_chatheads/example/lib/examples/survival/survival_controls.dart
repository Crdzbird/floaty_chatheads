part of '../survival_example.dart';

mixin _SurvivalControls on _SurvivalStore {
  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'survivalOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Survival Demo'),
      snap: const SnapConfig(edge: SnapEdge.both),
      contentWidth: 240,
      contentHeight: 340,
      entranceAnimation: EntranceAnimation.pop,
    );
    setState(() => _chatheadActive = true);
    await _kit.setState(SurvivalState(counter: _counter, label: 'Connected'));
  }

  void _close() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() {
      _chatheadActive = false;
      _counter = 0;
      _addLog('[closed] overlay dismissed');
    });
    unawaited(_persistCounter());
  }

  void _incrementFromMain() {
    _counter++;
    setState(() => _addLog('[main +1] counter = $_counter'));
    unawaited(_persistCounter());
    unawaited(
      _kit.setState(SurvivalState(counter: _counter, label: 'Main increment')),
    );
  }

  List<Widget> _appBarActions() {
    if (!_chatheadActive) {
      return [
        IconButton(
          icon: const Icon(Icons.rocket_launch),
          tooltip: 'Launch overlay',
          onPressed: () => unawaited(_launch()),
        ),
      ];
    }
    return [
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Increment from main',
        onPressed: _incrementFromMain,
      ),
      IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Close overlay',
        onPressed: _close,
      ),
    ];
  }
}
