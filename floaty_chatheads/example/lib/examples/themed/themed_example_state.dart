part of '../themed_example.dart';

final class _ThemedExampleState extends State<ThemedExample> {
  final _received = <String>[];
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (!mounted) return;
      setState(() {
        _received.insert(0, '$data');
        if (_received.length > 30) _received.removeLast();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Themed Chathead')),
      body: Column(
        children: [
          ThemedLaunchPanel(
            onPurple: () => unawaited(launchThemedPurple()),
            onGreen: () => unawaited(launchThemedGreen()),
            onClose: () => unawaited(FloatyChatheads.closeChatHead()),
          ),
          const Divider(),
          ThemedResponsesHeader(
            count: _received.length,
            onClear: () => setState(_received.clear),
          ),
          Expanded(child: ThemedResponsesList(responses: _received)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
