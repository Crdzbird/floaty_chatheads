import 'package:floaty_chatheads/floaty_chatheads.dart';

// ---------------------------------------------------------------------------
// Typed actions for the survival example (used by FloatyActionRouter)
// ---------------------------------------------------------------------------

/// Increments a shared counter.
class IncrementAction extends FloatyAction {
  IncrementAction({required this.amount});

  factory IncrementAction.fromJson(Map<String, dynamic> json) =>
      IncrementAction(amount: json['amount'] as int);

  final int amount;

  @override
  String get type => 'increment';

  @override
  Map<String, dynamic> toJson() => {'amount': amount};

  @override
  String toString() => 'Increment(+$amount)';
}

/// Sends a text message from the overlay to the main app.
class MessageAction extends FloatyAction {
  MessageAction({required this.text, required this.timestamp});

  factory MessageAction.fromJson(Map<String, dynamic> json) =>
      MessageAction(
        text: json['text'] as String,
        timestamp: json['timestamp'] as int,
      );

  final String text;
  final int timestamp;

  @override
  String get type => 'message';

  @override
  Map<String, dynamic> toJson() => {
        'text': text,
        'timestamp': timestamp,
      };

  @override
  String toString() => 'Message("$text")';
}

// ---------------------------------------------------------------------------
// Shared state for the survival example (used by FloatyStateChannel)
// ---------------------------------------------------------------------------

/// State synced between main app and overlay.
class SurvivalState {
  SurvivalState({
    this.counter = 0,
    this.label = 'Ready',
  });

  factory SurvivalState.fromJson(Map<String, dynamic> json) =>
      SurvivalState(
        counter: json['counter'] as int? ?? 0,
        label: json['label'] as String? ?? 'Ready',
      );

  final int counter;
  final String label;

  Map<String, dynamic> toJson() => {
        'counter': counter,
        'label': label,
      };
}
