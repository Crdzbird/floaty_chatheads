import 'package:pigeon/pigeon.dart';

/// Overlay-side Pigeon schema.
///
/// Only the Dart output is used; the native side is generated in the
/// platform-specific packages. The channel names MUST match the platform
/// packages so the overlay isolate talks to the same native handlers.
///
/// CONTRACT: every method here MUST use only standard-codec types
/// (int, double, String, Map, List; no custom classes or enums).
/// The native handlers are generated from the *platform* packages'
/// schemas, whose codecs assign different tags to custom types; a custom
/// type on these shared channels fails to decode across that boundary.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/floaty_chatheads_overlay_api.g.dart',
    dartPackageName: 'floaty_chatheads',
  ),
)
@HostApi()
abstract class FloatyOverlayHostApi {
  void resizeContent(int width, int height);

  /// [flagIndex] is the `OverlayFlag` enum index (standard-codec safe).
  void updateFlag(int flagIndex);

  void closeOverlay();

  /// Returns the overlay position as `{'x': double, 'y': double}`.
  Map<String?, Object?> getOverlayPosition();

  /// Updates the badge count from the overlay isolate.
  void updateBadgeFromOverlay(int count);

  /// Returns debug information when debugMode is enabled.
  ///
  /// Includes spring state, FPS, bounds, and Pigeon message log.
  Map<String?, Object?> getDebugInfo();
}

@FlutterApi()
abstract class FloatyOverlayFlutterApi {
  @asyncCallback
  void onChatHeadTapped(String id);

  @asyncCallback
  void onChatHeadClosed(String id);

  /// Called when the content panel is expanded.
  @asyncCallback
  void onChatHeadExpanded(String id);

  /// Called when the content panel is collapsed.
  @asyncCallback
  void onChatHeadCollapsed(String id);

  /// Called when the user starts dragging the chathead.
  @asyncCallback
  void onChatHeadDragStart(String id, double x, double y);

  /// Called when the user stops dragging the chathead.
  @asyncCallback
  void onChatHeadDragEnd(String id, double x, double y);
}
