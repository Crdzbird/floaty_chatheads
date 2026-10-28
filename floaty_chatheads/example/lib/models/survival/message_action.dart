import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Sends a text message from the overlay to the main app.
final class MessageAction extends FloatyAction {
  /// Creates a message action carrying [text] sent at [timestamp].
  const factory MessageAction({required String text, required int timestamp}) =
      MessageAction._;

  const MessageAction._({required this.text, required this.timestamp});

  /// Decodes an action from its JSON payload.
  factory MessageAction.fromJson(Map<String, dynamic> json) => MessageAction(
    text: json['text'] as String,
    timestamp: json['timestamp'] as int,
  );

  /// Routing key for this action type.
  static const key = ActionKey<MessageAction>(
    'message',
    MessageAction.fromJson,
  );

  /// The message text.
  final String text;

  /// When the message was sent, in milliseconds since epoch.
  final int timestamp;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'text': text, 'timestamp': timestamp};

  @override
  String toString() => 'Message("$text")';
}
