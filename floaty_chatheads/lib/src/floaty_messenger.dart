import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_overlay.dart';

/// {@template floaty_messenger}
/// Type-safe messaging wrapper for communication between the main app
/// and the overlay isolate.
///
/// Instead of sending raw `Object?` values and casting on the other side,
/// use [FloatyMessenger] with a serializer/deserializer pair:
///
/// **Main app side:**
///
/// ```dart
/// final messenger = FloatyMessenger<ChatMessage>(
///   serialize: (msg) => msg.toJson(),
///   deserialize: ChatMessage.fromJson,
/// );
///
/// // Send typed data.
/// messenger.send(ChatMessage(text: 'Hello!'));
///
/// // Receive typed data.
/// messenger.messages.listen((ChatMessage msg) {
///   print(msg.text);
/// });
/// ```
///
/// **Overlay side:**
///
/// ```dart
/// final messenger = FloatyMessenger<ChatMessage>.overlay(
///   serialize: (msg) => msg.toJson(),
///   deserialize: ChatMessage.fromJson,
/// );
/// ```
///
/// The `serialize` function converts `T` → JSON-compatible `Object?`
/// (Map, List, String, num, bool, or null).
/// The `deserialize` function converts `Object?` → `T`.
/// {@endtemplate}
final class FloatyMessenger<T> {
  /// {@template floaty_messenger.main}
  /// Creates a messenger for the **main app** side.
  ///
  /// Uses [FloatyChatheads.shareData] and [FloatyChatheads.onData].
  /// {@endtemplate}
  FloatyMessenger({
    required Object? Function(T value) serialize,
    required T Function(Object? raw) deserialize,
  })  : _serialize = serialize,
        _deserialize = deserialize,
        _isOverlay = false;

  /// {@template floaty_messenger.overlay}
  /// Creates a messenger for the **overlay** side.
  ///
  /// Uses [FloatyOverlay.shareData] and [FloatyOverlay.onData].
  /// {@endtemplate}
  FloatyMessenger.overlay({
    required Object? Function(T value) serialize,
    required T Function(Object? raw) deserialize,
  })  : _serialize = serialize,
        _deserialize = deserialize,
        _isOverlay = true;

  final Object? Function(T value) _serialize;
  final T Function(Object? raw) _deserialize;
  final bool _isOverlay;

  StreamSubscription<Object?>? _subscription;
  StreamController<T>? _controller;
  Stream<T>? _stream;

  /// {@template floaty_messenger.messages}
  /// A broadcast stream of deserialized messages of type [T].
  ///
  /// On the main-app side, this wraps [FloatyChatheads.onData].
  /// On the overlay side, this wraps [FloatyOverlay.onData].
  ///
  /// Each incoming `Object?` is passed through the deserializer before
  /// being emitted. If deserialization throws, the error is forwarded
  /// to the stream's error handler.
  /// {@endtemplate}
  Stream<T> get messages {
    if (_controller == null) {
      _controller = StreamController<T>.broadcast();
      _stream = _controller!.stream;
      final source = _isOverlay ? FloatyOverlay.onData : FloatyChatheads.onData;
      _subscription = source.listen(
        (raw) {
          try {
            _controller!.add(_deserialize(raw));
          } on Object catch (e, st) {
            _controller!.addError(e, st);
          }
        },
        onError: _controller!.addError,
      );
    }
    return _stream!;
  }

  /// {@template floaty_messenger.send}
  /// Serializes [value] and sends it to the other side.
  ///
  /// On the main-app side, this calls [FloatyChatheads.shareData].
  /// On the overlay side, this calls [FloatyOverlay.shareData].
  /// {@endtemplate}
  Future<void> send(T value) {
    final serialized = _serialize(value);
    return _isOverlay
        ? FloatyOverlay.shareData(serialized)
        : FloatyChatheads.shareData(serialized);
  }

  /// {@template floaty_messenger.dispose}
  /// Cancels the underlying stream subscription and closes the controller.
  /// {@endtemplate}
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_controller?.close());
    _controller = null;
    _stream = null;
  }
}
