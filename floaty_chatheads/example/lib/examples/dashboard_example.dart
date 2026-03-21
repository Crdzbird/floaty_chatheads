import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Demonstrates a near-fullscreen, scrollable overlay.
///
/// The overlay shows a notes dashboard that covers most of the screen.
/// The main app can push notes into the overlay via [FloatyChatheads.shareData].
class DashboardExample extends StatefulWidget {
  const DashboardExample({super.key});

  @override
  State<DashboardExample> createState() => _DashboardExampleState();
}

class _DashboardExampleState extends State<DashboardExample> {
  final _log = <String>[];
  StreamSubscription<Object?>? _sub;
  StreamSubscription<String>? _closeSub;
  bool _chatheadActive = false;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        final event = data['event'] ?? 'unknown';
        final title = data['title'] ?? '';
        setState(() {
          _log.insert(0, '$event: $title (${data['count']} notes)');
          if (_log.length > 30) _log.removeLast();
        });
      }
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    // contentWidth/contentHeight = -1 → native uses MATCH_PARENT,
    // giving the overlay the full screen from the start.
    await FloatyChatheads.showChatHead(
      entryPoint: 'dashboardOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Dashboard Active'),
      contentWidth: -1,
      contentHeight: -1,
    );
    setState(() => _chatheadActive = true);
  }

  void _pushNote() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty) return;
    FloatyChatheads.shareData({
      'action': 'addNote',
      'title': title,
      'body': body.isEmpty ? 'Sent from main app' : body,
    });
    _titleController.clear();
    _bodyController.clear();
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
              onPressed: _launch,
            ),
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close chathead',
              onPressed: () {
                FloatyChatheads.closeChatHead();
                setState(() => _chatheadActive = false);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_chatheadActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade400),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap the dashboard icon in the app bar to launch '
                      'a near-fullscreen scrollable overlay.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Push note section
          if (_chatheadActive)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Push a note to the overlay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Note title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bodyController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Note body (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pushNote,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Push Note to Overlay'),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Event log (${_log.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_log.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_log.clear),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _log.isEmpty
                ? const Center(
                    child: Text(
                      'Events from the overlay will appear here.\n'
                      'Add or remove notes in the overlay to see events.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _log[i],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeSub?.cancel();
    _sub?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    FloatyChatheads.closeChatHead();
    super.dispose();
  }
}
