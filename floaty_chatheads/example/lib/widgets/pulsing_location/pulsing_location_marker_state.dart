part of '../pulsing_location_marker.dart';

final class _PulsingLocationMarkerState extends State<PulsingLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerMax = widget.size * 2.2;
    return SizedBox(
      width: outerMax,
      height: outerMax,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PulsingLocationRing(animation: _ctrl, size: widget.size),
            PulsingLocationDot(size: widget.size + 4, color: Colors.white),
            PulsingLocationDot(size: widget.size, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
