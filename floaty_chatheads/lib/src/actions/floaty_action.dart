/// Base class for typed actions dispatched between main app and overlay.
///
/// Subclass this to define your own action types:
///
/// ```dart
/// class PinAction extends FloatyAction {
///   PinAction({required this.lat, required this.lng});
///
///   factory PinAction.fromJson(Map<String, dynamic> json) =>
///       PinAction(lat: json['lat'] as double, lng: json['lng'] as double);
///
///   static const key = ActionKey<PinAction>('pin', PinAction.fromJson);
///
///   final double lat;
///   final double lng;
///
///   @override
///   String get type => key.type;
///
///   @override
///   Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
/// }
/// ```
abstract class FloatyAction {
  /// Base constructor for subclasses.
  const FloatyAction();

  /// Unique type string used for routing (e.g. `'pin'`, `'navigate'`).
  String get type;

  /// Serializes the action payload to a JSON-compatible map.
  Map<String, dynamic> toJson();
}
