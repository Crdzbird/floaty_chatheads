import 'package:pigeon/pigeon.dart';

/// Overlay-side Pigeon schema.
///
/// Only the Dart output is used — the native side is generated in the
/// platform-specific packages. The channel names MUST match the platform
/// packages so the overlay isolate talks to the same native handlers.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/floaty_chatheads_overlay_api.g.dart',
    dartPackageName: 'floaty_chatheads',
  ),
)
enum OverlayFlagMessage {
  defaultFlag,
  clickThrough,
  focusPointer,
}

class OverlayPositionMessage {
  OverlayPositionMessage({required this.x, required this.y});

  final double x;
  final double y;
}

@HostApi()
abstract class FloatyOverlayHostApi {
  void resizeContent(int width, int height);

  void updateFlag(OverlayFlagMessage flag);

  void closeOverlay();

  OverlayPositionMessage getOverlayPosition();

  /// Updates the badge count from the overlay isolate.
  void updateBadgeFromOverlay(int count);

  /// Returns debug information when debugMode is enabled.
  ///
  /// Includes spring state, FPS, bounds, and Pigeon message log.
  Map<String?, Object?> getDebugInfo();
}

@FlutterApi()
abstract class FloatyOverlayFlutterApi {
  void onChatHeadTapped(String id);

  void onChatHeadClosed(String id);

  /// Called when the content panel is expanded.
  void onChatHeadExpanded(String id);

  /// Called when the content panel is collapsed.
  void onChatHeadCollapsed(String id);

  /// Called when the user starts dragging the chathead.
  void onChatHeadDragStart(String id, double x, double y);

  /// Called when the user stops dragging the chathead.
  void onChatHeadDragEnd(String id, double x, double y);
}
