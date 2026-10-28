part of '../dashboard_overlay.dart';

final class _DashboardOverlayState extends State<DashboardOverlay> {
  final _notes = dashboardSeedNotes();
  late final StreamSubscription<Object?> _dataSub;
  int _noteCount = 0;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is! Map || data['action'] != 'addNote' || !mounted) return;
      setState(() {
        _notes.insert(
          0,
          DashboardNote(
            title: '${data['title'] ?? 'New Note'}',
            body: '${data['body'] ?? ''}',
            color: Colors.blueGrey,
          ),
        );
      });
    });
  }

  Future<void> _addNote() async {
    _noteCount++;
    final note = DashboardNote(
      title: 'Note #$_noteCount',
      body:
          'Created from overlay at '
          '${TimeOfDay.now().format(context)}.',
      color: Colors.primaries[_noteCount % Colors.primaries.length],
    );
    setState(() => _notes.insert(0, note));
    await FloatyOverlay.shareData({
      'event': 'noteAdded',
      'title': note.title,
      'count': _notes.length,
    });
  }

  Future<void> _removeNote(int index) async {
    final removed = _notes[index];
    setState(() => _notes.removeAt(index));
    await FloatyOverlay.shareData({
      'event': 'noteRemoved',
      'title': removed.title,
      'count': _notes.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dashboardBg,
      child: Column(
        children: [
          DashboardHeader(onAdd: () => unawaited(_addNote())),
          DashboardStatsRow(
            total: _notes.length,
            pinned: _notes.where((n) => n.pinned).length,
            added: _noteCount,
          ),
          const Divider(height: 1, color: dashboardDivider),
          Expanded(
            child: DashboardNotesList(
              notes: _notes,
              onRemove: (index) => unawaited(_removeNote(index)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_dataSub.cancel());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
