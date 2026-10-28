/// A chat message in the fullscreen messenger overlay.
final class FullscreenChatMessage {
  /// Creates a message; [isMe] marks messages sent from the overlay.
  const factory FullscreenChatMessage({
    required String text,
    required bool isMe,
    required String time,
  }) = FullscreenChatMessage._;

  const FullscreenChatMessage._({
    required this.text,
    required this.isMe,
    required this.time,
  });

  /// Message text.
  final String text;

  /// Whether the overlay user sent this message.
  final bool isMe;

  /// Display time, for example "10:30 AM".
  final String time;
}
