/// Sample state used by the FloatyOverlayScope tests.
final class ScopeTestState {
  /// Creates a state with the given [counter] and [label].
  factory ScopeTestState({int counter, String label}) = ScopeTestState._;

  /// Decodes a state from its JSON map.
  factory ScopeTestState.fromJson(Map<String, dynamic> json) => ScopeTestState(
    counter: json['counter'] as int? ?? 0,
    label: json['label'] as String? ?? 'ready',
  );

  ScopeTestState._({this.counter = 0, this.label = 'ready'});

  /// A counter value.
  final int counter;

  /// A text label.
  final String label;

  /// Encodes this state as a JSON map.
  Map<String, dynamic> toJson() => {'counter': counter, 'label': label};
}
