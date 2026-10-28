part of '../dashboard_example.dart';

final class _DashboardExampleState extends State<DashboardExample>
    with _DashboardExampleLogic {
  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overlay'),
        actions: [
          if (!_chatheadActive)
            IconButton(
              icon: const Icon(Icons.dashboard),
              tooltip: 'Launch dashboard',
              onPressed: () => unawaited(_launch()),
            ),
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close chathead',
              onPressed: _closeChathead,
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_chatheadActive)
            const DashboardInfoBanner(
              text: 'Tap the dashboard icon in the app bar to launch '
                  'a near-fullscreen scrollable overlay.',
            ),
          if (_chatheadActive)
            DashboardNoteForm(
              titleController: _titleController,
              bodyController: _bodyController,
              onPush: () => unawaited(_pushNote()),
            ),
          const Divider(height: 1),
          DashboardLogHeader(
            label: 'Event log',
            count: _log.length,
            onClear: () => setState(_log.clear),
          ),
          Expanded(
            child: DashboardLogList(
              entries: _log,
              fontSize: 12,
              emptyText: 'Events from the overlay will appear here.\n'
                  'Add or remove notes in the overlay to see events.',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeLogic();
    super.dispose();
  }
}
