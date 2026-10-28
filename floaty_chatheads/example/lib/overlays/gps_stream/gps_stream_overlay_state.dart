part of '../gps_stream_overlay.dart';

final class _GpsStreamOverlayState extends State<GpsStreamOverlay> {
  late final FloatyProxyStream<GpsCoord> _gpsStream;
  StreamSubscription<GpsCoord>? _sub;

  GpsCoord? _current;
  int _count = 0;

  @override
  void initState() {
    super.initState();

    _gpsStream = FloatyProxyStream.overlay(GpsCoord.streamKey);

    _sub = _gpsStream.stream.listen((coord) {
      if (!mounted) return;
      setState(() {
        _current = coord;
        _count++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final coord = _current;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GpsOverlayHeader(count: _count),
              if (coord == null) const GpsWaitingView(),
              if (coord != null) GpsReadingView(coord: coord),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(_gpsStream.dispose());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
