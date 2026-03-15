import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/floaty_chatheads_api.g.dart',
    dartPackageName: 'floaty_chatheads',
    swiftOut:
        'ios/floaty_chatheads_ios/Sources/floaty_chatheads_ios/FloatyChatheadsApi.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
enum OverlayFlagMessage {
  defaultFlag,
  clickThrough,
  focusPointer,
}

enum NotificationVisibilityMessage {
  visibilityPublic,
  visibilitySecret,
  visibilityPrivate,
}

/// Which screen edge(s) the chathead snaps to after being released.
enum SnapEdgeMessage {
  /// Snap to the nearest horizontal edge (left or right). Default.
  both,

  /// Always snap to the left edge.
  left,

  /// Always snap to the right edge.
  right,

  /// No snapping — the bubble stays where the user releases it.
  none,
}

/// Animation style used when the chathead first appears on screen.
enum EntranceAnimationMessage {
  /// No entrance animation — bubble appears at its initial position.
  none,

  /// Bubble pops in with a scale spring (default).
  pop,

  /// Bubble slides in from the nearest edge.
  slideFromEdge,

  /// Bubble fades in.
  fade,
}

/// Theming configuration for the chathead.
///
/// All color values are ARGB integers.
class ChatHeadThemeMessage {
  ChatHeadThemeMessage({
    this.badgeColor,
    this.badgeTextColor,
    this.bubbleBorderColor,
    this.bubbleBorderWidth,
    this.bubbleShadowColor,
    this.closeTintColor,
    this.overlayPalette,
  });

  final int? badgeColor;
  final int? badgeTextColor;
  final int? bubbleBorderColor;
  final double? bubbleBorderWidth;
  final int? bubbleShadowColor;
  final int? closeTintColor;

  /// Color palette forwarded to the overlay isolate.
  /// Keys: primary, secondary, surface, background, onPrimary, etc.
  final Map<String?, int?>? overlayPalette;
}

class ChatHeadConfig {
  ChatHeadConfig({
    required this.entryPoint,
    this.contentWidth,
    this.contentHeight,
    this.chatheadIconAsset,
    this.closeIconAsset,
    this.closeBackgroundAsset,
    this.notificationTitle,
    this.notificationIconAsset,
    required this.flag,
    required this.enableDrag,
    required this.notificationVisibility,
    required this.snapEdge,
    required this.snapMargin,
    required this.persistPosition,
    required this.entranceAnimation,
    this.theme,
    required this.debugMode,
  });

  final String entryPoint;
  final int? contentWidth;
  final int? contentHeight;
  final String? chatheadIconAsset;
  final String? closeIconAsset;
  final String? closeBackgroundAsset;
  final String? notificationTitle;
  final String? notificationIconAsset;
  final OverlayFlagMessage flag;
  final bool enableDrag;
  final NotificationVisibilityMessage notificationVisibility;

  /// Which screen edge(s) the chathead snaps to.
  final SnapEdgeMessage snapEdge;

  /// Margin (in dp) from the screen edge when snapped.
  /// Negative values mean the bubble overlaps the edge (partially hidden).
  final double snapMargin;

  /// Whether to save and restore the chathead position across sessions.
  final bool persistPosition;

  /// The entrance animation when the chathead first appears.
  final EntranceAnimationMessage entranceAnimation;

  /// Optional theme configuration.
  final ChatHeadThemeMessage? theme;

  /// Whether to enable the debug overlay inspector.
  final bool debugMode;
}

class OverlayPositionMessage {
  OverlayPositionMessage({required this.x, required this.y});

  final double x;
  final double y;
}

class AddChatHeadConfig {
  AddChatHeadConfig({required this.id, this.iconAsset});

  final String id;
  final String? iconAsset;
}

@HostApi()
abstract class FloatyHostApi {
  bool checkPermission();

  @async
  bool requestPermission();

  void showChatHead(ChatHeadConfig config);

  void closeChatHead();

  bool isChatHeadActive();

  void addChatHead(AddChatHeadConfig config);

  void removeChatHead(String id);

  /// Updates the badge count on the chathead bubble.
  /// Pass 0 to hide the badge.
  void updateBadge(int count);

  /// Programmatically expands the chathead to show its content panel.
  void expandChatHead();

  /// Programmatically collapses the chathead content panel.
  void collapseChatHead();
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
