part of 'home_page.dart';

final class _HomePageState extends State<HomePage> {
  int _counter = 0;
  final _received = <String>[];
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = Floaty.onData.listen((data) {
      if (!mounted) return;
      setState(() {
        _received.insert(0, '$data');
        if (_received.length > 50) _received.removeLast();
      });
    });
  }

  Future<void> _sendData() async {
    _counter++;
    await Floaty.send({'counter': _counter, 'from': 'main app'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Chathead')),
      body: Column(
        children: [
          BasicControls(
            counter: _counter,
            onShow: () => unawaited(Floaty.show(title: 'Basic Chathead')),
            onSend: () => unawaited(_sendData()),
            onClose: () => unawaited(Floaty.close()),
          ),
          const Divider(),
          ReceivedHeader(
            count: _received.length,
            onClear: () => setState(_received.clear),
          ),
          Expanded(child: ReceivedList(messages: _received)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(Floaty.close());
    super.dispose();
  }
}
