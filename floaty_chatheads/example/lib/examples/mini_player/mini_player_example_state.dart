part of '../mini_player_example.dart';

final class _MiniPlayerExampleState extends State<MiniPlayerExample> {
  static const _playlist = miniPlayerTracks;

  int _currentIndex = 0;
  bool _isPlaying = false;
  StreamSubscription<Object?>? _sub;

  Map<String, String> get _currentTrack => _playlist[_currentIndex];

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is! Map || !mounted) return;
      final action = data['action'];
      if (action is! String) return;
      final change = switch (action) {
        'toggle' => _togglePlaying,
        'next' => _nextTrack,
        'prev' => _prevTrack,
        _ => null,
      };
      if (change != null) setState(change);
      unawaited(_pushState());
    });
  }

  void _togglePlaying() => _isPlaying = !_isPlaying;

  void _nextTrack() => _currentIndex = (_currentIndex + 1) % _playlist.length;

  void _prevTrack() =>
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;

  void _apply(VoidCallback change) {
    setState(change);
    unawaited(_pushState());
  }

  Future<void> _pushState() => FloatyChatheads.shareData({
    'title': _currentTrack['title'],
    'artist': _currentTrack['artist'],
    'isPlaying': _isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Player')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(launchMiniPlayer()),
        icon: const Icon(Icons.music_note),
        label: const Text('Launch Player'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          MiniPlayerNowPlaying(
            title: _currentTrack['title']!,
            artist: _currentTrack['artist']!,
            isPlaying: _isPlaying,
          ),
          const SizedBox(height: 20),
          MiniPlayerTransport(
            isPlaying: _isPlaying,
            onPrev: () => _apply(_prevTrack),
            onToggle: () => _apply(_togglePlaying),
            onNext: () => _apply(_nextTrack),
          ),
          const Divider(height: 32),
          Expanded(
            child: MiniPlayerPlaylist(
              tracks: _playlist,
              currentIndex: _currentIndex,
              isPlaying: _isPlaying,
              onSelect: (i) => _apply(() {
                _currentIndex = i;
                _isPlaying = true;
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(FloatyChatheads.closeChatHead());
    super.dispose();
  }
}
