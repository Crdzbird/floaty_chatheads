import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../models/survival_actions.dart';
import '../utils.dart';

/// Demonstrates overlay survival after app death using [FloatyHostKit]
/// for simplified wiring.
///
/// 1. **Connection state** — the overlay shows a live connected /
///    disconnected banner via `FloatyConnectionState`.
/// 2. **Action queueing** — actions dispatched while disconnected are
///    queued and flushed when the app reconnects.
/// 3. **Proxy fallback** — proxy calls return a fallback value instead
///    of timing out when the main app is unavailable.
///
/// **How to test:**
///
///  1. Tap "Launch Overlay" to show the chathead.
///  2. See the green "Connected" banner in the overlay.
///  3. Force-stop the app from recent apps.
///  4. The overlay stays visible — banner turns red "Disconnected".
///  5. Tap "+1" in the overlay — actions are queued (badge shows count).
///  6. Tap "Server Time" — shows fallback instead of timing out.
///  7. Re-open the app — banner turns green, queued actions flush into
///     the log below.
class SurvivalExample extends StatefulWidget {
  const SurvivalExample({super.key});

  @override
  State<SurvivalExample> createState() => _SurvivalExampleState();
}

class _SurvivalExampleState extends State<SurvivalExample> {
  bool _chatheadActive = false;
  int _counter = 0;
  final _log = <String>[];
  static const _maxLogEntries = 50;

  late final FloatyHostKit<SurvivalState> _kit;

  void _addLog(String entry) {
    _log.insert(0, entry);
    if (_log.length > _maxLogEntries) _log.removeLast();
  }

  @override
  void initState() {
    super.initState();

    _kit = FloatyHostKit<SurvivalState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: SurvivalState.fromJson,
      initialState: SurvivalState(),
    );

    // Handle increment actions from the overlay.
    _kit.onAction<IncrementAction>(
      'increment',
      fromJson: IncrementAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        setState(() {
          _counter += action.amount;
          _addLog('[+${action.amount}] counter = $_counter');
        });
        // Sync updated counter back to overlay.
        unawaited(
          _kit.setState(SurvivalState(
            counter: _counter,
            label: 'Updated from main',
          )),
        );
      },
    );

    // Handle message actions from the overlay.
    _kit.onAction<MessageAction>(
      'message',
      fromJson: MessageAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        setState(() => _addLog(action.text));
      },
    );

    // Expose a "time" service to the overlay.
    _kit.registerService('time', (method, params) {
      if (method == 'now') {
        final now = DateTime.now();
        return {
          'iso': now.toIso8601String(),
          'millis': now.millisecondsSinceEpoch,
        };
      }
      return null;
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'survivalOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Survival Demo'),
      snap: const SnapConfig(edge: SnapEdge.both),
      contentWidth: 240,
      contentHeight: 340,
      entranceAnimation: EntranceAnimation.pop,
    );
    setState(() => _chatheadActive = true);

    // Sync initial state.
    await _kit.setState(SurvivalState(
      counter: _counter,
      label: 'Connected',
    ));
  }

  void _close() {
    FloatyChatheads.closeChatHead();
    setState(() => _chatheadActive = false);
  }

  void _incrementFromMain() {
    _counter++;
    setState(() => _addLog('[main +1] counter = $_counter'));
    unawaited(
      _kit.setState(SurvivalState(
        counter: _counter,
        label: 'Main increment',
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Survival'),
        actions: [
          if (!_chatheadActive)
            IconButton(
              icon: const Icon(Icons.rocket_launch),
              tooltip: 'Launch overlay',
              onPressed: _launch,
            ),
          if (_chatheadActive) ...[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Increment from main',
              onPressed: _incrementFromMain,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close overlay',
              onPressed: _close,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.deepOrange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to test:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1. Launch the overlay\n'
                  '2. Force-stop this app from recents\n'
                  '3. Overlay stays — banner turns red\n'
                  '4. Tap +1 in overlay (actions queue)\n'
                  '5. Re-open app — actions flush here',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          // Counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.tag,
                  color: Colors.deepOrange.shade300,
                ),
                const SizedBox(width: 8),
                Text(
                  'Counter: $_counter',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Log header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  'Action Log (${_log.length})',
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
          // Log list
          Expanded(
            child: _log.isEmpty
                ? const Center(
                    child: Text(
                      'Actions from the overlay will appear here.\n'
                      'Try killing the app and sending\n'
                      'actions from the overlay!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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
    _kit.dispose();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
