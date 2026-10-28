import 'package:geolocator/geolocator.dart';

/// Returns true when location services are on and permission is granted,
/// requesting permission once if it was denied.
Future<bool> isGpsAvailable() async {
  if (!await Geolocator.isLocationServiceEnabled()) return false;
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission != LocationPermission.denied &&
      permission != LocationPermission.deniedForever;
}
