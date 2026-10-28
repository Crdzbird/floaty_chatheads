/// State synced between main app and overlay in the survival example.
final class SurvivalState {
  /// Creates a state with a [counter] value and a status [label].
  const factory SurvivalState({int counter, String label}) = SurvivalState._;

  const SurvivalState._({this.counter = 0, this.label = 'Ready'});

  /// Decodes a state from its JSON form.
  factory SurvivalState.fromJson(Map<String, dynamic> json) => SurvivalState(
    counter: json['counter'] as int? ?? 0,
    label: json['label'] as String? ?? 'Ready',
  );

  /// The shared counter value.
  final int counter;

  /// A short label describing the last update.
  final String label;

  /// Encodes this state as JSON.
  Map<String, dynamic> toJson() => {'counter': counter, 'label': label};
}
