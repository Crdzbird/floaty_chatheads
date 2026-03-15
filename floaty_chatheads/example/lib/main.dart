import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'examples/accessibility_example.dart';
import 'examples/dashboard_example.dart';
import 'examples/features_showcase_example.dart';
import 'examples/map_example.dart';
import 'examples/messenger_example.dart';
import 'examples/messenger_fullscreen_example.dart';
import 'examples/mini_player_example.dart';
import 'examples/multi_chathead_example.dart';
import 'examples/notification_counter_example.dart';
import 'examples/quick_action_example.dart';
import 'examples/survival_example.dart';
import 'examples/themed_example.dart';
import 'examples/timer_example.dart';
import 'overlays/accessibility_overlay.dart';
import 'overlays/dashboard_overlay.dart';
import 'overlays/features_showcase_overlay.dart';
import 'overlays/map_overlay.dart';
import 'overlays/messenger_fullscreen_overlay.dart';
import 'overlays/messenger_overlay.dart';
import 'overlays/mini_player_overlay.dart';
import 'overlays/multi_chat_overlay.dart';
import 'overlays/notification_counter_overlay.dart';
import 'overlays/quick_action_overlay.dart';
import 'overlays/survival_overlay.dart';
import 'overlays/themed_overlay.dart';
import 'overlays/timer_overlay.dart';
import 'utils.dart';

void main() => runApp(const MaterialApp(home: GalleryPage()));

// ---------------------------------------------------------------------------
// Overlay entry points — must be top-level for AOT discoverability.
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayContent(),
    ),
  );
}

@pragma('vm:entry-point')
void messengerOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MessengerOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void miniPlayerOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MiniPlayerOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void quickActionOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuickActionOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void counterOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationCounterOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void timerOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimerOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void multiChatOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiChatOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void dashboardOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void messengerFullscreenOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MessengerFullscreenOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void featuresOverlayMain() {
  debugPrint('featuresOverlayMain: entry point executing');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeaturesShowcaseOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void themedOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ThemedOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void mapOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void accessibilityOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccessibilityOverlay(),
    ),
  );
}

@pragma('vm:entry-point')
void survivalOverlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SurvivalOverlay(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Gallery — lists all examples
// ---------------------------------------------------------------------------

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  static const _examples = <_ExampleInfo>[
    _ExampleInfo(
      title: 'Basic (Original)',
      description: 'Simple chathead with show, close, and send data buttons.',
      icon: Icons.bubble_chart,
      color: Colors.teal,
    ),
    _ExampleInfo(
      title: 'Messenger Chat',
      description: 'Bidirectional messaging between main app and overlay.',
      icon: Icons.chat,
      color: Colors.indigo,
    ),
    _ExampleInfo(
      title: 'Mini Player',
      description: 'Media transport controls with state sync.',
      icon: Icons.music_note,
      color: Colors.deepPurple,
    ),
    _ExampleInfo(
      title: 'Quick Actions',
      description: 'Click-through FAB buttons with action logging.',
      icon: Icons.bolt,
      color: Colors.orange,
    ),
    _ExampleInfo(
      title: 'Notification Counter',
      description: 'Reactive badge that updates from main app data.',
      icon: Icons.notifications,
      color: Colors.red,
    ),
    _ExampleInfo(
      title: 'Timer / Stopwatch',
      description: 'Persistent timer with dynamic resize and lap tracking.',
      icon: Icons.timer,
      color: Colors.blueGrey,
    ),
    _ExampleInfo(
      title: 'Multi-Chathead',
      description: 'Multiple bubbles that expand in a row (Messenger-style).',
      icon: Icons.group,
      color: Colors.cyan,
    ),
    _ExampleInfo(
      title: 'Dashboard (Fullscreen)',
      description:
          'Near-fullscreen scrollable notes overlay with rich content.',
      icon: Icons.dashboard,
      color: Colors.blue,
    ),
    _ExampleInfo(
      title: 'Messenger (Fullscreen)',
      description: 'Facebook Messenger-style: bubble at top, full chat below.',
      icon: Icons.mark_chat_read,
      color: Color(0xFF0084FF),
    ),
    _ExampleInfo(
      title: 'Features Showcase',
      description:
          'Badge count, programmatic expand/collapse, lifecycle events.',
      icon: Icons.science,
      color: Colors.amber,
    ),
    _ExampleInfo(
      title: 'Themed Chathead',
      description:
          'Custom badge colors, bubble border, close tint, overlay palette.',
      icon: Icons.palette,
      color: Colors.deepPurple,
    ),
    _ExampleInfo(
      title: 'Accessibility / TalkBack',
      description:
          'TalkBack testing with semantic labels and large touch targets.',
      icon: Icons.accessibility_new,
      color: Colors.blue,
    ),
    _ExampleInfo(
      title: 'Interactive Map',
      description:
          'OSM map with action routing, state sync, and proxy features.',
      icon: Icons.map,
      color: Colors.green,
    ),
    _ExampleInfo(
      title: 'Overlay Survival',
      description:
          'Kill the app — overlay survives, queues actions, reconnects.',
      icon: Icons.shield,
      color: Colors.deepOrange,
    ),
  ];

  Widget _buildRoute(int index) {
    return switch (index) {
      0 => const HomePage(),
      1 => const MessengerExample(),
      2 => const MiniPlayerExample(),
      3 => const QuickActionExample(),
      4 => const NotificationCounterExample(),
      5 => const TimerExample(),
      6 => const MultiChatheadExample(),
      7 => const DashboardExample(),
      8 => const MessengerFullscreenExample(),
      9 => const FeaturesShowcaseExample(),
      10 => const ThemedExample(),
      11 => const AccessibilityExample(),
      12 => const MapExample(),
      13 => const SurvivalExample(),
      _ => const HomePage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floaty Chathead Examples'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _examples.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final info = _examples[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: info.color,
                child: Icon(info.icon, color: Colors.white),
              ),
              title: Text(info.title),
              subtitle: Text(info.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _buildRoute(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExampleInfo {
  const _ExampleInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

// ---------------------------------------------------------------------------
// Basic example — shows/closes chathead, sends data both ways, displays
// received messages in a scrollable log.
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  final _received = <String>[];
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (mounted) {
        setState(() {
          _received.insert(0, '$data');
          if (_received.length > 50) _received.removeLast();
        });
      }
    });
  }

  Future<void> _showChatHead() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      chatheadIconAsset: 'assets/chatheadIcon.png',
      closeIconAsset: 'assets/close.png',
      closeBackgroundAsset: 'assets/closeBg.png',
      notificationTitle: 'Chathead Active',
      notificationIconAsset: 'assets/notificationIcon.png',
    );
  }

  void _sendData() {
    _counter++;
    FloatyChatheads.shareData({'counter': _counter, 'from': 'main app'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Chathead')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _showChatHead,
                  icon: const Icon(Icons.bubble_chart),
                  label: const Text('Show Chathead'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sendData,
                        icon: const Icon(Icons.send),
                        label: Text('Send #$_counter'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => FloatyChatheads.closeChatHead(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Received from overlay (${_received.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_received.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_received.clear),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _received.isEmpty
                ? const Center(
                    child: Text(
                      'Tap the chathead, then press\n"Send to Main" in the overlay',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _received.length,
                    itemBuilder: (_, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _received[i],
                          style: const TextStyle(fontSize: 13),
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
    _sub?.cancel();
    FloatyChatheads.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Basic overlay — shows received data, sends data back to main app.
// ---------------------------------------------------------------------------

class OverlayContent extends StatefulWidget {
  const OverlayContent({super.key});

  @override
  State<OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<OverlayContent> {
  String _lastReceived = 'No data yet';
  int _sendCount = 0;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    FloatyOverlay.onData.listen((data) {
      if (mounted) {
        setState(() => _lastReceived = '$data');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(8),
          color: Colors.teal.shade700,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Overlay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _lastReceived,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _sendCount++;
                    FloatyOverlay.shareData({
                      'message': 'Hello #$_sendCount',
                      'from': 'overlay',
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Send to Main',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: FloatyOverlay.closeOverlay,
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    FloatyOverlay.dispose();
    super.dispose();
  }
}
