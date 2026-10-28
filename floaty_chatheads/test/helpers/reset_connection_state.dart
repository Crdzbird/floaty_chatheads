import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';

/// Clears [FloatyConnectionState] and the shared [FloatyChannel].
void resetConnectionState() {
  FloatyConnectionState.dispose();
  FloatyChannel.reset();
}
