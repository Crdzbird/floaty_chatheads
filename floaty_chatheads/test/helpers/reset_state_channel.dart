import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';

/// Clears the static chathead, overlay and channel state between tests.
void resetStateChannel() {
  FloatyChatheads.dispose();
  FloatyOverlay.dispose();
  FloatyChannel.reset();
}
