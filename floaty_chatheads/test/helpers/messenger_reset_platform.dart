import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Installs a fresh [FakeFloatyPlatform] and resets static messenger state.
void messengerResetPlatform() {
  final fake = FakeFloatyPlatform();
  FloatyChatheadsPlatform.instance = fake;
  FloatyChatheads.dispose();
  FloatyOverlay.dispose();
}
