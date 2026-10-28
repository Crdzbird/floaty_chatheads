/// Formats [d] as zero padded minutes and seconds, for example 03:07.
String formatTimerOverlay(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
