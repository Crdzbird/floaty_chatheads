import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Compact media-player overlay with transport controls.
///
/// Receives track info from the main app via [FloatyOverlay.onData]
/// and sends play/pause/next/prev actions back.
class MiniPlayerOverlay extends StatefulWidget {
  const MiniPlayerOverlay({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay> {
  String _title = 'No track';
  String _artist = '';
  bool _isPlaying = false;
  late final StreamSubscription<Object?> _dataSub;
  late final StreamSubscription<String> _tapSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is Map && mounted) {
        setState(() {
          if (data['title'] != null) _title = '${data['title']}';
          if (data['artist'] != null) _artist = '${data['artist']}';
          if (data['isPlaying'] is bool) _isPlaying = data['isPlaying'] as bool;
        });
      }
    });

    // Tap on the chathead bubble toggles play/pause.
    _tapSub = FloatyOverlay.onTapped.listen((id) => _sendAction('toggle'));

    // Ask main app for current state on startup.
    FloatyOverlay.shareData({'action': 'requestState'});
  }

  void _sendAction(String action) {
    FloatyOverlay.shareData({'action': action});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(8),
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Track info
                Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_artist.isNotEmpty)
                  Text(
                    _artist,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // Transport controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ControlBtn(
                      icon: Icons.skip_previous,
                      onTap: () => _sendAction('prev'),
                    ),
                    const SizedBox(width: 14),
                    _ControlBtn(
                      icon: _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 32,
                      onTap: () => _sendAction('toggle'),
                    ),
                    const SizedBox(width: 14),
                    _ControlBtn(
                      icon: Icons.skip_next,
                      onTap: () => _sendAction('next'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: FloatyOverlay.closeOverlay,
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
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
    _dataSub.cancel();
    _tapSub.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    required this.onTap,
    this.size = 24,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}
