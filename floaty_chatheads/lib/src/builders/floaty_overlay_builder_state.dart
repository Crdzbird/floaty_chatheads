part of '../floaty_overlay_builder.dart';

final class _FloatyOverlayBuilderState<T>
    extends State<FloatyOverlayBuilder<T>> {
  late T _state;
  final _subs = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _state = widget.initialState;
    _subs.add(
      FloatyOverlay.onData.listen((data) {
        if (!mounted) return;
        setState(() => _state = widget.onData(_state, data));
      }),
    );
    if (widget.onTapped != null) {
      _subs.add(
        FloatyOverlay.onTapped.listen((id) {
          if (!mounted) return;
          setState(() => _state = widget.onTapped!(_state, id));
        }),
      );
    }
    widget.onInit?.call();
  }

  @override
  void dispose() {
    unawaited(Future.wait(_subs.map((s) => s.cancel())));
    FloatyOverlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _state);
}
