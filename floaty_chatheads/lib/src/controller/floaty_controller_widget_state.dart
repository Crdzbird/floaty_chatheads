part of 'floaty_controller_widget.dart';

final class _FloatyControllerWidgetState extends State<FloatyControllerWidget> {
  late FloatyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloatyController(
      entryPoint: widget.entryPoint,
      sizePreset: widget.sizePreset,
      theme: widget.theme,
      debugMode: widget.debugMode,
      onData: widget.onData,
      autoShow: true,
      assets: widget.assets,
      notification: widget.notification,
      snap: widget.snap,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    if (builder == null) return widget.child!;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => builder(context, _controller),
    );
  }
}
