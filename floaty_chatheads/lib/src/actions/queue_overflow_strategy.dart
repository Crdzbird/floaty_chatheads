/// Strategy for handling queue overflow when the maximum queue size
/// is reached while the main app is disconnected.
enum QueueOverflowStrategy {
  /// Drop the oldest queued action to make room for the new one.
  dropOldest,

  /// Drop the newest (incoming) action when the queue is full.
  dropNewest,
}
