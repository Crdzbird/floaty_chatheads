part of '../widget_icon_example.dart';

final class _WidgetIconExampleState extends State<WidgetIconExample> {
  bool _animating = false;

  Future<void> _launchAnimated(Future<bool> Function() launch) async {
    if (!await launch()) return;
    setState(() => _animating = true);
  }

  void _toggleAnimation() {
    if (FloatyChatheads.isIconAnimating) {
      FloatyChatheads.stopIconAnimation();
      setState(() => _animating = false);
      return;
    }
    FloatyChatheads.startIconAnimation();
    setState(() => _animating = true);
  }

  void _close() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() => _animating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Icons')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WidgetIconStaticSection(
            onTextAvatar: () => unawaited(launchWidgetIconTextAvatar()),
            onGradient: () => unawaited(launchWidgetIconGradient()),
            onCustomClose: () => unawaited(launchWidgetIconCustomClose()),
          ),
          const SizedBox(height: 24),
          WidgetIconAnimatedSection(
            onSpinning: () =>
                unawaited(_launchAnimated(launchWidgetIconSpinningSync)),
            onPulsing: () =>
                unawaited(_launchAnimated(launchWidgetIconPulsingAlert)),
          ),
          const SizedBox(height: 24),
          WidgetIconControls(
            animating: _animating,
            onToggle: _toggleAnimation,
            onClose: _close,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
