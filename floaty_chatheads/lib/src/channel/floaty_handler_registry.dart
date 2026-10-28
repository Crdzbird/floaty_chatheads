import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Prefix-keyed handlers for system messages on the shared channel.
///
/// Messages for a prefix that has never had a handler are buffered (up to
/// [maxPending] per prefix) and replayed when one registers. Once a prefix
/// has been registered and removed, its messages are no longer buffered.
final class FloatyHandlerRegistry {
  /// Creates an empty registry.
  factory FloatyHandlerRegistry() = FloatyHandlerRegistry._;

  FloatyHandlerRegistry._();

  /// Maximum buffered messages per prefix.
  static const maxPending = 200;

  final Map<String, void Function(Map<String, dynamic>)> _handlers = {};
  final Map<String, List<Map<String, dynamic>>> _pending = {};
  final Set<String> _everRegistered = {};

  /// Registers [handler] for [prefix] and replays buffered messages.
  void register(
    String prefix,
    void Function(Map<String, dynamic> data) handler,
  ) {
    _handlers[prefix] = handler;
    _everRegistered.add(prefix);
    final buffered = _pending.remove(prefix);
    if (buffered != null && buffered.isNotEmpty) buffered.forEach(handler);
  }

  /// Removes the handler for [prefix].
  void unregister(String prefix) => _handlers.remove(prefix);

  /// Delivers or buffers [message] when it is a well formed system
  /// message. Returns `false` when it belongs on the raw stream.
  bool route(Map<dynamic, dynamic> message) {
    if (!message.containsKey(FloatyChannels.envelope)) return false;
    final prefix = message[FloatyChannels.envelope] as String?;
    final raw = prefix != null ? message[prefix] : null;
    if (prefix == null || raw is! Map) return false;
    final data = raw.cast<String, dynamic>();
    final handler = _handlers[prefix];
    if (handler != null) {
      handler(data);
      return true;
    }
    if (_everRegistered.contains(prefix)) return false;
    final queue = _pending.putIfAbsent(prefix, () => []);
    if (queue.length < maxPending) queue.add(data);
    return true;
  }

  /// Forgets every handler and buffered message.
  void clear() {
    _handlers.clear();
    _pending.clear();
    _everRegistered.clear();
  }
}
