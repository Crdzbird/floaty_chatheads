import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Mini player example: main app has a playlist, overlay shows
/// compact transport controls. State syncs bidirectionally.
class MiniPlayerExample extends StatefulWidget {
  const MiniPlayerExample({super.key});

  @override
  State<MiniPlayerExample> createState() => _MiniPlayerExampleState();
}

class _MiniPlayerExampleState extends State<MiniPlayerExample> {
  static const _playlist = [
    {'title': 'Sunset Drive', 'artist': 'Lo-Fi Beats'},
    {'title': 'Ocean Waves', 'artist': 'Nature Sounds'},
    {'title': 'City Lights', 'artist': 'Synthwave FM'},
    {'title': 'Mountain Air', 'artist': 'Ambient Works'},
    {'title': 'Rainy Day', 'artist': 'Jazz Cafe'},
  ];

  int _currentIndex = 0;
  bool _isPlaying = false;
  StreamSubscription<Object?>? _sub;

  Map<String, String> get _currentTrack => _playlist[_currentIndex];

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        final action = data['action'];
        if (action is String) {
          switch (action) {
            case 'toggle':
              setState(() => _isPlaying = !_isPlaying);
            case 'next':
              setState(() {
                _currentIndex = (_currentIndex + 1) % _playlist.length;
              });
            case 'prev':
              setState(() {
                _currentIndex =
                    (_currentIndex - 1 + _playlist.length) % _playlist.length;
              });
            case 'requestState':
              // Overlay just started, send current state.
              break;
          }
          _pushState();
        }
      }
    });
  }

  void _pushState() {
    FloatyChatheads.shareData({
      'title': _currentTrack['title'],
      'artist': _currentTrack['artist'],
      'isPlaying': _isPlaying,
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'miniPlayerOverlayMain',
      chatheadIconAsset: 'assets/chatheadIcon.png',
      closeIconAsset: 'assets/close.png',
      closeBackgroundAsset: 'assets/closeBg.png',
      notificationTitle: 'Mini Player Active',
      contentWidth: 260,
      contentHeight: 160,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Player')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launch,
        icon: const Icon(Icons.music_note),
        label: const Text('Launch Player'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Now playing
          Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 80,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          Text(
            _currentTrack['title']!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            _currentTrack['artist']!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36),
                onPressed: () {
                  setState(() {
                    _currentIndex =
                        (_currentIndex - 1 + _playlist.length) %
                            _playlist.length;
                  });
                  _pushState();
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 48,
                ),
                onPressed: () {
                  setState(() => _isPlaying = !_isPlaying);
                  _pushState();
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36),
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % _playlist.length;
                  });
                  _pushState();
                },
              ),
            ],
          ),
          const Divider(height: 32),
          // Playlist
          Expanded(
            child: ListView.builder(
              itemCount: _playlist.length,
              itemBuilder: (_, i) {
                final track = _playlist[i];
                final isCurrent = i == _currentIndex;
                return ListTile(
                  leading: Icon(
                    isCurrent && _isPlaying
                        ? Icons.equalizer
                        : Icons.music_note,
                    color: isCurrent ? Colors.deepPurple : Colors.grey,
                  ),
                  title: Text(
                    track['title']!,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Colors.deepPurple : null,
                    ),
                  ),
                  subtitle: Text(track['artist']!),
                  onTap: () {
                    setState(() {
                      _currentIndex = i;
                      _isPlaying = true;
                    });
                    _pushState();
                  },
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
    _sub?.cancel();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
