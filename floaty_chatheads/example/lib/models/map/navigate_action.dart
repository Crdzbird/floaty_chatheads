import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Navigates the map to the given coordinates.
final class NavigateAction extends FloatyAction {
  /// Creates a navigate action to [lat], [lng].
  const factory NavigateAction({required double lat, required double lng}) =
      NavigateAction._;

  const NavigateAction._({required this.lat, required this.lng});

  /// Decodes a navigate action from its JSON payload.
  factory NavigateAction.fromJson(Map<String, dynamic> json) => NavigateAction(
        lat: json['lat'] as double,
        lng: json['lng'] as double,
      );

  /// Routing key for navigate actions.
  static const key =
      ActionKey<NavigateAction>('navigate', NavigateAction.fromJson);

  /// Target latitude.
  final double lat;

  /// Target longitude.
  final double lng;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}
