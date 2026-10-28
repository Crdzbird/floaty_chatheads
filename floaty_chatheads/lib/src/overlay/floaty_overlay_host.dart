import 'package:floaty_chatheads/src/generated/floaty_chatheads_overlay_api.g.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart'
    show OverlayPosition;

/// Calls from the overlay isolate into the native overlay host.
final class FloatyOverlayHost {
  FloatyOverlayHost._();

  /// The generated Pigeon host API.
  static final FloatyOverlayHostApi api = FloatyOverlayHostApi();

  /// Reads the overlay position from its `{'x': num, 'y': num}` reply.
  static Future<OverlayPosition> position() async {
    final msg = await api.getOverlayPosition();
    return OverlayPosition(
      x: (msg['x']! as num).toDouble(),
      y: (msg['y']! as num).toDouble(),
    );
  }

  /// Reads the native debug information with string keys.
  static Future<Map<String, Object?>> debugInfo() async {
    final raw = await api.getDebugInfo();
    return raw.map((k, v) => MapEntry(k?.toString() ?? '', v));
  }
}
