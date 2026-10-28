/// State synced between main app and overlay.
final class MapSyncState {
  /// Creates a map state; zoom defaults to 13 and tracking to off.
  const factory MapSyncState({
    double? centerLat,
    double? centerLng,
    double zoom,
    bool tracking,
  }) = MapSyncState._;

  const MapSyncState._({
    this.centerLat,
    this.centerLng,
    this.zoom = 13.0,
    this.tracking = false,
  });

  /// Decodes a map state from its JSON payload.
  factory MapSyncState.fromJson(Map<String, dynamic> json) => MapSyncState(
        centerLat: json['centerLat'] as double?,
        centerLng: json['centerLng'] as double?,
        zoom: (json['zoom'] as num?)?.toDouble() ?? 13.0,
        tracking: json['tracking'] as bool? ?? false,
      );

  /// Latitude of the map center, if known.
  final double? centerLat;

  /// Longitude of the map center, if known.
  final double? centerLng;

  /// Map zoom level.
  final double zoom;

  /// Whether simulated tracking is on.
  final bool tracking;

  /// Encodes this state as JSON.
  Map<String, dynamic> toJson() => {
        'centerLat': centerLat,
        'centerLng': centerLng,
        'zoom': zoom,
        'tracking': tracking,
      };
}
