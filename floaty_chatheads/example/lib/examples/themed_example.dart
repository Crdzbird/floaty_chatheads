import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Theming example: demonstrates custom badge colors, bubble border,
/// close tint, shadow color, and overlay palette delivery.
class ThemedExample extends StatefulWidget {
  const ThemedExample({super.key});

  @override
  State<ThemedExample> createState() => _ThemedExampleState();
}

class _ThemedExampleState extends State<ThemedExample> {
  final _received = <String>[];
  StreamSubscription<Object?>? _sub;

  // Current theme settings
  final Color _badgeColor = Colors.deepPurple;
  final Color _badgeTextColor = Colors.white;
  final Color _borderColor = Colors.deepPurpleAccent;
  final double _borderWidth = 2;
  final Color _closeTint = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (mounted) {
        setState(() {
          _received.insert(0, '$data');
          if (_received.length > 30) _received.removeLast();
        });
      }
    });
  }

  Future<void> _launchThemed() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'themedOverlayMain',
      chatheadIconAsset: 'assets/chatheadIcon.png',
      closeIconAsset: 'assets/close.png',
      closeBackgroundAsset: 'assets/closeBg.png',
      notificationTitle: 'Themed Chathead',
      contentWidth: 220,
      contentHeight: 320,
      theme: ChatHeadTheme(
        badgeColor: _badgeColor.toARGB32(),
        badgeTextColor: _badgeTextColor.toARGB32(),
        bubbleBorderColor: _borderColor.toARGB32(),
        bubbleBorderWidth: _borderWidth,
        closeTintColor: _closeTint.toARGB32(),
        overlayPalette: {
          'primary': Colors.deepPurple.toARGB32(),
          'secondary': Colors.amber.toARGB32(),
          'surface': Colors.white.toARGB32(),
          'background': const Color(0xFFF5F0FF).toARGB32(),
          'onPrimary': Colors.white.toARGB32(),
          'onSecondary': Colors.black.toARGB32(),
          'onSurface': Colors.black87.toARGB32(),
          'error': Colors.red.toARGB32(),
          'onError': Colors.white.toARGB32(),
        },
      ),
    );
    // Set a badge to show themed badge colors.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await FloatyChatheads.updateBadge(3);
  }

  Future<void> _launchGreen() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'themedOverlayMain',
      chatheadIconAsset: 'assets/chatheadIcon.png',
      closeIconAsset: 'assets/close.png',
      closeBackgroundAsset: 'assets/closeBg.png',
      notificationTitle: 'Green Theme',
      contentWidth: 220,
      contentHeight: 320,
      theme: ChatHeadTheme(
        badgeColor: Colors.green.toARGB32(),
        badgeTextColor: Colors.white.toARGB32(),
        bubbleBorderColor: Colors.green.shade700.toARGB32(),
        bubbleBorderWidth: 3,
        closeTintColor: Colors.green.shade900.toARGB32(),
        overlayPalette: {
          'primary': Colors.green.toARGB32(),
          'secondary': Colors.lightGreen.toARGB32(),
          'surface': const Color(0xFFF0FFF0).toARGB32(),
          'background': Colors.white.toARGB32(),
          'onPrimary': Colors.white.toARGB32(),
          'onSecondary': Colors.black.toARGB32(),
          'onSurface': Colors.black87.toARGB32(),
          'error': Colors.red.toARGB32(),
          'onError': Colors.white.toARGB32(),
        },
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await FloatyChatheads.updateBadge(7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Themed Chathead')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Launch a chathead with custom theme colors.\n'
                  'Badge, border, close tint, and overlay palette are all customizable.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _launchThemed,
                  icon: const Icon(Icons.palette),
                  label: const Text('Purple Theme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _launchGreen,
                  icon: const Icon(Icons.eco),
                  label: const Text('Green Theme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => FloatyChatheads.closeChatHead(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
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
                  'Overlay responses (${_received.length})',
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
                      'Launch a themed chathead and interact with the overlay',
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
    _sub?.cancel();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
