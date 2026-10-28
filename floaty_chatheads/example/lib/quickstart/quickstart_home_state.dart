part of 'quickstart_home.dart';

final class _QuickstartHomeState extends State<QuickstartHome> {
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    FloatyChatheads.onData.listen((data) {
      setState(() => _status = 'Received: $data');
    });
  }

  Future<void> _launch() async {
    final shown = await Floaty.show(title: 'Quickstart');
    setState(() => _status = shown ? 'Chathead shown' : 'Permission denied');
  }

  Future<void> _send() async {
    await FloatyChatheads.shareData('Hello from app!');
    setState(() => _status = 'Sent message');
  }

  Future<void> _close() async {
    await FloatyChatheads.closeChatHead();
    setState(() => _status = 'Closed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quickstart')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_status),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => unawaited(_launch()),
              child: const Text('Show Chathead'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => unawaited(_send()),
              child: const Text('Send Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => unawaited(_close()),
              child: const Text('Close Chathead'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
