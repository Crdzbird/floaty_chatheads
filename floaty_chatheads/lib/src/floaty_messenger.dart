import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_overlay.dart';

/// Type-safe messaging between the main app and the overlay isolate.
///
/// Instead of sending raw `Object?` values and casting on the other side,
/// pair a serializer with a deserializer:
///
/// ```dart
/// final messenger = FloatyMessenger<ChatMessage>(
///   serialize: (msg) => msg.toJson(),
///   deserialize: ChatMessage.fromJson,
/// );
/// await messenger.send(ChatMessage(text: 'Hello!'));
/// messenger.messages.listen((msg) => print(msg.text));
/// ```
///
/// Use [FloatyMessenger.overlay] on the overlay side. `serialize` turns a
/// `T` into a JSON-compatible value; `deserialize` turns it back.
final class FloatyMessenger<T> {
  /// Creates a messenger for the main app side, backed by
  /// [FloatyChatheads.shareData] and [FloatyChatheads.onData].
  factory FloatyMessenger({
    required Object? Function(T value) serialize,
    required T Function(Object? raw) deserialize,
  }) = FloatyMessenger<T>._main;

  /// Creates a messenger for the overlay side, backed by
  /// [FloatyOverlay.shareData] and [FloatyOverlay.onData].
  factory FloatyMessenger.overlay({
    required Object? Function(T value) serialize,
    required T Function(Object? raw) deserialize,
  }) = FloatyMessenger<T>._overlay;

  FloatyMessenger._main({required this._serialize, required this._deserialize})
    : _isOverlay = false;

  FloatyMessenger._overlay({
    required this._serialize,
    required this._deserialize,
  }) : _isOverlay = true;

  final Object? Function(T value) _serialize;
  final T Function(Object? raw) _deserialize;
  final bool _isOverlay;

  StreamSubscription<Object?>? _subscription;
  StreamController<T>? _controller;
  Stream<T>? _stream;

  /// A broadcast stream of deserialized messages of type [T].
  ///
  /// If deserialization throws, the error is forwarded to the stream.
  Stream<T> get messages => _stream ??= (_controller = _listen()).stream;

  StreamController<T> _listen() {
    final controller = StreamController<T>.broadcast();
    final source = _isOverlay ? FloatyOverlay.onData : FloatyChatheads.onData;
    _subscription = source.listen((raw) {
      try {
        controller.add(_deserialize(raw));
      } on Object catch (e, st) {
        controller.addError(e, st);
      }
    }, onError: controller.addError);
    return controller;
  }

  /// Serializes [value] and sends it to the other side.
  Future<void> send(T value) {
    final serialized = _serialize(value);
    return _isOverlay
        ? FloatyOverlay.shareData(serialized)
        : FloatyChatheads.shareData(serialized);
  }

  /// Cancels the underlying stream subscription and closes the controller.
  Future<void> dispose() async {
    await Future.wait([
      if (_subscription != null) _subscription!.cancel(),
      if (_controller != null) _controller!.close(),
    ]);
    _subscription = null;
    _controller = null;
    _stream = null;
  }
}
