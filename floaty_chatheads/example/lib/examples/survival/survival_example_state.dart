part of '../survival_example.dart';

final class _SurvivalExampleState extends State<SurvivalExample>
    with _SurvivalStore, _SurvivalWiring, _SurvivalControls {
  StreamSubscription<String>? _closeSub;

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });
    _wireKit();
    unawaited(_restoreAndReconnect());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Survival'),
        actions: _appBarActions(),
      ),
      body: Column(
        children: [
          const SurvivalInstructions(),
          SurvivalCounterRow(counter: _counter),
          const Divider(),
          SurvivalLogHeader(
            count: _log.length,
            onClear: () => setState(_log.clear),
          ),
          Expanded(child: SurvivalLogList(entries: _log)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_closeSub?.cancel());
    unawaited(_kit.dispose());
    super.dispose();
  }
}
