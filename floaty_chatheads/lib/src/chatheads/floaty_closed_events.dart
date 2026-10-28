import 'dart:async';

import 'package:floaty_chatheads/src/chatheads/floaty_icon_animation.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';

/// Main-app-side stream of chathead IDs closed by the user or overlay.
final class FloatyClosedEvents {
  FloatyClosedEvents._();

  static const _prefix = '_floaty_closed';

  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static bool _registered = false;

  /// Emits the ID of each closed chathead, attaching the channel handler
  /// on first access.
  static Stream<String> get stream {
    _ensureHandler();
    FloatyChannel.ensureListening();
    return _controller.stream;
  }

  static void _ensureHandler() {
    if (_registered) return;
    FloatyChannel.registerHandler(_prefix, (data) {
      final id = data['id'] as String? ?? 'default';
      FloatyIconAnimation.disposeIfOwnedBy(id);
      _controller.add(id);
    });
    _registered = true;
  }

  /// Removes the channel handler; the next [stream] access re-attaches it.
  static void reset() {
    FloatyChannel.unregisterHandler(_prefix);
    _registered = false;
  }
}
