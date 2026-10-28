import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Drops a pin at the given coordinates.
final class PinAction extends FloatyAction {
  /// Creates a pin action at [lat], [lng].
  const factory PinAction({required double lat, required double lng}) =
      PinAction._;

  const PinAction._({required this.lat, required this.lng});

  /// Decodes a pin action from its JSON payload.
  factory PinAction.fromJson(Map<String, dynamic> json) => PinAction(
        lat: json['lat'] as double,
        lng: json['lng'] as double,
      );

  /// Routing key for pin actions.
  static const key = ActionKey<PinAction>('pin', PinAction.fromJson);

  /// Latitude of the pin.
  final double lat;

  /// Longitude of the pin.
  final double lng;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}
