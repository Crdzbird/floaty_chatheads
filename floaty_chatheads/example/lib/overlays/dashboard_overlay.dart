import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Near-fullscreen scrollable overlay that displays a notes dashboard.
///
/// Uses a fully opaque dark background so no app content bleeds through.
/// Demonstrates rich scrollable content in an overlay panel.
class DashboardOverlay extends StatefulWidget {
  const DashboardOverlay({super.key});

  @override
  State<DashboardOverlay> createState() => _DashboardOverlayState();
}

class _DashboardOverlayState extends State<DashboardOverlay> {
  final _notes = <_Note>[
    _Note(
      title: 'Welcome!',
      body: 'This is a near-fullscreen overlay with scrollable content. '
          'Try scrolling down to see more notes.',
      color: Colors.indigo,
      pinned: true,
    ),
    _Note(
      title: 'Shopping List',
      body: '• Milk\n• Eggs\n• Bread\n• Coffee\n• Bananas',
      color: Colors.teal,
    ),
    _Note(
      title: 'Meeting Notes',
      body: 'Discussed project timeline, assigned tasks to team members. '
          'Follow up next Monday for progress update.',
      color: Colors.deepOrange,
    ),
    _Note(
      title: 'Ideas',
      body: '1. Build a weather widget overlay\n'
          '2. Add voice memo support\n'
          '3. Integrate calendar events\n'
          '4. Dark mode toggle',
      color: Colors.purple,
    ),
    _Note(
      title: 'Reminders',
      body: '• Call dentist at 3 PM\n'
          '• Pick up dry cleaning\n'
          '• Reply to email from Sarah\n'
          '• Buy birthday gift',
      color: Colors.amber,
    ),
    _Note(
      title: 'Quote of the Day',
      body: '"The best way to predict the future is to create it." '
          '— Peter Drucker',
      color: Colors.cyan,
    ),
    _Note(
      title: 'Workout Plan',
      body: 'Mon: Upper body\n'
          'Tue: Cardio\n'
          'Wed: Lower body\n'
          'Thu: Rest\n'
          'Fri: Full body\n'
          'Sat: Yoga\n'
          'Sun: Rest',
      color: Colors.green,
    ),
  ];

  late final StreamSubscription<Object?> _dataSub;
  int _noteCount = 0;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    // No resizeContent call needed — the native side already started
    // the panel at MATCH_PARENT (contentWidth/contentHeight omitted
    // in showChatHead).

    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is Map && data['action'] == 'addNote' && mounted) {
        setState(() {
          _notes.insert(
            0,
            _Note(
              title: '${data['title'] ?? 'New Note'}',
              body: '${data['body'] ?? ''}',
              color: Colors.blueGrey,
            ),
          );
        });
      }
    });
  }

  void _addNote() {
    _noteCount++;
    final note = _Note(
      title: 'Note #$_noteCount',
      body: 'Created from overlay at '
          '${TimeOfDay.now().format(context)}.',
      color: Colors.primaries[_noteCount % Colors.primaries.length],
    );
    setState(() => _notes.insert(0, note));
    FloatyOverlay.shareData({
      'event': 'noteAdded',
      'title': note.title,
      'count': _notes.length,
    });
  }

  void _removeNote(int index) {
    final removed = _notes[index];
    setState(() => _notes.removeAt(index));
    FloatyOverlay.shareData({
      'event': 'noteRemoved',
      'title': removed.title,
      'count': _notes.length,
    });
  }

  static const _bg = Color(0xFF1E1E2E);
  static const _surface = Color(0xFF2A2A3C);
  static const _textPrimary = Color(0xFFE0E0F0);
  static const _textSecondary = Color(0xFF9090A8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      child: Column(
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
            decoration: const BoxDecoration(
              color: _surface,
              border: Border(
                bottom: BorderSide(color: Color(0xFF3A3A4C)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.indigoAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Notes Dashboard',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _ActionChip(
                  icon: Icons.add_rounded,
                  label: 'New',
                  color: Colors.indigoAccent,
                  onTap: _addNote,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: FloatyOverlay.closeOverlay,
                  child: const Icon(Icons.close_rounded,
                      color: _textSecondary, size: 22),
                ),
              ],
            ),
          ),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: _bg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBadge(
                  label: 'Total',
                  value: '${_notes.length}',
                  icon: Icons.note_rounded,
                  color: Colors.indigoAccent,
                ),
                _StatBadge(
                  label: 'Pinned',
                  value: '${_notes.where((n) => n.pinned).length}',
                  icon: Icons.push_pin_rounded,
                  color: Colors.amber,
                ),
                _StatBadge(
                  label: 'Added',
                  value: '$_noteCount',
                  icon: Icons.add_circle_outline_rounded,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF3A3A4C)),
          // Scrollable notes list
          Expanded(
            child: _notes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_add_rounded,
                            size: 48, color: _textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'No notes yet',
                          style:
                              TextStyle(color: _textSecondary, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap "New" to create one',
                          style:
                              TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return _NoteCard(
                        note: note,
                        onDismiss: () => _removeNote(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dataSub.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: _DashboardOverlayState._textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onDismiss});

  final _Note note;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _DashboardOverlayState._surface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: note.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (note.pinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.push_pin_rounded,
                              size: 12,
                              color: note.color,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: note.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onDismiss,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: _DashboardOverlayState._textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.body,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: _DashboardOverlayState._textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _Note {
  _Note({
    required this.title,
    required this.body,
    required this.color,
    this.pinned = false,
  });

  final String title;
  final String body;
  final Color color;
  final bool pinned;
}
