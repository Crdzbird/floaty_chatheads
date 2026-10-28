import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Checks overlay permission and requests it if not granted.
/// Returns `true` if the permission is available.
Future<bool> ensureOverlayPermission() async {
  if (await FloatyChatheads.checkPermission()) return true;
  return await FloatyChatheads.requestPermission();
}
