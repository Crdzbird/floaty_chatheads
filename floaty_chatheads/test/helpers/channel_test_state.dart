/// Sample state used by the FloatyStateChannel tests.
final class ChannelTestState {
  /// Creates a state with the given [count] and [label].
  factory ChannelTestState({int count, String label}) = ChannelTestState._;

  /// Decodes a state from its JSON map.
  factory ChannelTestState.fromJson(Map<String, dynamic> json) =>
      ChannelTestState(
        count: json['count'] as int? ?? 0,
        label: json['label'] as String? ?? '',
      );

  ChannelTestState._({this.count = 0, this.label = ''});

  /// A counter value.
  final int count;

  /// A text label.
  final String label;

  /// Encodes this state as a JSON map.
  Map<String, dynamic> toJson() => {'count': count, 'label': label};
}
