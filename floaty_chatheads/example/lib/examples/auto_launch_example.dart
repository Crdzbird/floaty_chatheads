import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Demonstrates [ChatHeadConfig.autoLaunchOnBackground] and
/// [ChatHeadConfig.persistOnAppClose].
///
/// **`autoLaunchOnBackground`** — When enabled, the chathead automatically
/// appears when the app moves to the background and is dismissed when the
/// app returns to the foreground. This is useful for music players, call
/// UIs, or any feature that needs a persistent floating widget while the
/// user is in another app.
///
/// **`persistOnAppClose`** — When enabled, the overlay service uses
/// `START_STICKY` so it survives even after the main app process is killed.
/// When disabled, the service stops itself as soon as the main app
/// disconnects.
///
/// **How to test:**
///
///  1. Toggle the switches and tap "Enable".
///  2. Press the device's home button or switch to another app.
///  3. The chathead should appear automatically (if auto-launch is on).
///  4. Return to the app — the chathead is automatically dismissed.
///  5. With "Persist on app close" on, force-stop the app: the chathead
///     remains. With it off, the chathead disappears.
class AutoLaunchExample extends StatefulWidget {
  const AutoLaunchExample({super.key});

  @override
  State<AutoLaunchExample> createState() => _AutoLaunchExampleState();
}

class _AutoLaunchExampleState extends State<AutoLaunchExample> {
  bool _autoLaunch = true;
  bool _persist = false;
  bool _enabled = false;
  StreamSubscription<String>? _closeSub;

  Future<void> _enable() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(
        title: 'Auto-Launch Demo',
        description: 'Chathead will appear when you leave the app.',
        iconAsset: 'assets/notificationIcon.png',
      ),
      contentWidth: 260,
      contentHeight: 180,
      autoLaunchOnBackground: _autoLaunch,
      persistOnAppClose: _persist,
    );
    await _closeSub?.cancel();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _enabled = false);
    });
    setState(() => _enabled = true);
  }

  Future<void> _disable() async {
    await FloatyChatheads.closeChatHead();
    setState(() => _enabled = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Launch & Persist')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Auto-launch on background'),
                      subtitle: const Text(
                        'Show chathead when the app is backgrounded, '
                        'dismiss when foregrounded.',
                      ),
                      value: _autoLaunch,
                      onChanged: _enabled
                          ? null
                          : (v) => setState(() => _autoLaunch = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      title: const Text('Persist on app close'),
                      subtitle: const Text(
                        'Keep the chathead alive even after the main '
                        'app process is killed.',
                      ),
                      value: _persist,
                      onChanged: _enabled
                          ? null
                          : (v) => setState(() => _persist = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _enabled ? _disable : _enable,
              icon: Icon(_enabled ? Icons.stop : Icons.play_arrow),
              label: Text(_enabled ? 'Disable' : 'Enable'),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to test',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Toggle the switches above and tap Enable.\n'
                        '2. Press Home or switch to another app.\n'
                        '3. The chathead appears automatically.\n'
                        '4. Return to this app — chathead is dismissed.\n\n'
                        'With "Persist on app close" ON:\n'
                        '• Force-stop the app — chathead survives.\n\n'
                        'With "Persist on app close" OFF:\n'
                        '• Force-stop the app — chathead disappears.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeSub?.cancel();
    if (_enabled) FloatyChatheads.closeChatHead();
    super.dispose();
  }
}
