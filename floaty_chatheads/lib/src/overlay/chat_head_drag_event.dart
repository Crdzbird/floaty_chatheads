/// Event emitted when a chathead drag starts or ends.
///
/// Contains the chathead [id] and its position ([x], [y]) in physical
/// pixels.
final class ChatHeadDragEvent {
  /// Creates a drag event for chathead [id] at ([x], [y]).
  const factory ChatHeadDragEvent({
    required String id,
    required double x,
    required double y,
  }) = ChatHeadDragEvent._;

  const ChatHeadDragEvent._({
    required this.id,
    required this.x,
    required this.y,
  });

  /// The ID of the chathead being dragged.
  final String id;

  /// The X position of the chathead (in physical pixels).
  final double x;

  /// The Y position of the chathead (in physical pixels).
  final double y;

  @override
  String toString() => 'ChatHeadDragEvent(id: $id, x: $x, y: $y)';
}
