import 'package:floaty_chatheads/floaty_chatheads.dart';

// ---------------------------------------------------------------------------
// Typed actions for the map example (used by FloatyActionRouter)
// ---------------------------------------------------------------------------

/// Drops a pin at the given coordinates.
class PinAction extends FloatyAction {
  PinAction({required this.lat, required this.lng});

  factory PinAction.fromJson(Map<String, dynamic> json) => PinAction(
        lat: json['lat'] as double,
        lng: json['lng'] as double,
      );

  final double lat;
  final double lng;

  @override
  String get type => 'pin';

  @override
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// Navigates the map to the given coordinates.
class NavigateAction extends FloatyAction {
  NavigateAction({required this.lat, required this.lng});

  factory NavigateAction.fromJson(Map<String, dynamic> json) =>
      NavigateAction(
        lat: json['lat'] as double,
        lng: json['lng'] as double,
      );

  final double lat;
  final double lng;

  @override
  String get type => 'navigate';

  @override
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

// ---------------------------------------------------------------------------
// Shared state for the map example (used by FloatyStateChannel)
// ---------------------------------------------------------------------------

/// State synced between main app and overlay.
class MapSyncState {
  MapSyncState({
    this.centerLat,
    this.centerLng,
    this.zoom = 13.0,
    this.tracking = false,
  });

  factory MapSyncState.fromJson(Map<String, dynamic> json) =>
      MapSyncState(
        centerLat: json['centerLat'] as double?,
        centerLng: json['centerLng'] as double?,
        zoom: (json['zoom'] as num?)?.toDouble() ?? 13.0,
        tracking: json['tracking'] as bool? ?? false,
      );

  final double? centerLat;
  final double? centerLng;
  final double zoom;
  final bool tracking;

  Map<String, dynamic> toJson() => {
        'centerLat': centerLat,
        'centerLng': centerLng,
        'zoom': zoom,
        'tracking': tracking,
      };
}
