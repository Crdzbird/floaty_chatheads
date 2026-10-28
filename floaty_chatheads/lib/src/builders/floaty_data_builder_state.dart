part of '../floaty_data_builder.dart';

final class _FloatyDataBuilderState<T> extends State<FloatyDataBuilder<T>> {
  late T _data;
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _sub = FloatyChatheads.onData.listen((raw) {
      if (!mounted) return;
      setState(() => _data = widget.onData(_data, raw));
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _data);
}
