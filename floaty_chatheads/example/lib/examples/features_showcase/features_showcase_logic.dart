part of '../features_showcase_example.dart';

mixin _FeaturesShowcaseLogic on State<FeaturesShowcaseExample> {
  int _badgeCount = 0;
  final _events = <String>[];
  SnapEdge _snapEdge = SnapEdge.both;
  EntranceAnimation _entranceAnimation = EntranceAnimation.pop;
  PanelAnchor _panelAnchor = PanelAnchor.below;
  bool _persistPosition = false;

  void _onData(Object? data) {
    if (!mounted) return;
    setState(() {
      _events.insert(0, 'Data: $data');
      _trimEvents();
    });
  }

  void _trimEvents() {
    while (_events.length > 30) {
      _events.removeLast();
    }
  }

  Future<void> _showChatHead() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'featuresOverlayMain',
      contentWidth: 320,
      contentHeight: 400,
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Features Showcase'),
      snap: SnapConfig(
        edge: _snapEdge,
        margin: -10,
        persistPosition: _persistPosition,
      ),
      entranceAnimation: _entranceAnimation,
      panelAnchor: _panelAnchor,
    );
    if (!mounted) return;
    setState(() => _events.insert(0, 'Chathead shown'));
  }

  void _incrementBadge() {
    setState(() => _badgeCount++);
    unawaited(FloatyChatheads.updateBadge(_badgeCount));
    _events.insert(0, 'Badge set to $_badgeCount');
  }

  void _clearBadge() {
    setState(() => _badgeCount = 0);
    unawaited(FloatyChatheads.updateBadge(0));
    _events.insert(0, 'Badge cleared');
  }

  void _expand() {
    unawaited(FloatyChatheads.expandChatHead());
    _events.insert(0, 'Expand requested');
    if (mounted) setState(() {});
  }

  void _collapse() {
    unawaited(FloatyChatheads.collapseChatHead());
    _events.insert(0, 'Collapse requested');
    if (mounted) setState(() {});
  }
}
