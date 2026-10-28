/// Serializable state used by the kit tests.
final class KitTestState {
  /// Creates a state with the given [counter] and [label].
  factory KitTestState({int counter, String label}) = KitTestState._;

  /// Restores a state from its JSON form.
  factory KitTestState.fromJson(Map<String, dynamic> json) => KitTestState(
    counter: json['counter'] as int? ?? 0,
    label: json['label'] as String? ?? 'ready',
  );

  KitTestState._({this.counter = 0, this.label = 'ready'});

  /// A numeric counter.
  final int counter;

  /// A text label.
  final String label;

  /// Serializes this state to JSON.
  Map<String, dynamic> toJson() => {'counter': counter, 'label': label};
}
