import 'dart:async';

/// Broadcast stream of raw channel messages that keeps messages arriving
/// before the first listener and replays them when one subscribes.
///
/// After the first listener, messages are broadcast as they arrive, like
/// any broadcast stream.
final class FloatyRawBuffer {
  /// Creates an empty buffer.
  factory FloatyRawBuffer() = FloatyRawBuffer._;

  FloatyRawBuffer._();

  /// Maximum number of messages kept before the first listener.
  static const maxPending = 200;

  late final StreamController<Object?> _controller =
      StreamController<Object?>.broadcast(onListen: _flush);

  final List<Object?> _pending = [];

  bool _everListened = false;

  /// The raw message stream.
  Stream<Object?> get stream => _controller.stream;

  /// Broadcasts [message], or buffers it while nobody has listened yet.
  void emit(Object? message) {
    if (_everListened || _controller.hasListener) {
      _controller.add(message);
      return;
    }
    if (_pending.length < maxPending) _pending.add(message);
  }

  /// Drops buffered messages and waits for a first listener again.
  void reset() {
    _pending.clear();
    _everListened = false;
  }

  void _flush() {
    _everListened = true;
    final buffered = List<Object?>.of(_pending);
    _pending.clear();
    buffered.forEach(_controller.add);
  }
}
