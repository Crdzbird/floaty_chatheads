import 'package:flutter/foundation.dart';

/// A chat message exchanged between the main app and the overlay.
@immutable
final class MessengerMessage {
  /// Creates a message sent by [sender] with the given [text].
  const factory MessengerMessage({
    required String sender,
    required String text,
  }) = MessengerMessage._;

  const MessengerMessage._({required this.sender, required this.text});

  /// Who sent the message: `app` or `overlay`.
  final String sender;

  /// The message body.
  final String text;
}
