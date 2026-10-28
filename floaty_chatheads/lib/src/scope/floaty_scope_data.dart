import 'package:floaty_chatheads/src/floaty_overlay.dart';

/// Snapshot of the latest overlay state exposed by `FloatyScope`. A new
/// snapshot is built whenever one of the overlay streams emits.
final class FloatyScopeData {
  /// Creates a snapshot; every field defaults to its empty value.
  const factory FloatyScopeData({
    Object? lastMessage,
    String? lastTappedId,
    String? lastClosedId,
    String? lastExpandedId,
    String? lastCollapsedId,
    ChatHeadDragEvent? lastDragStart,
    ChatHeadDragEvent? lastDragEnd,
    OverlayColorPalette? palette,
    List<Object?> messages,
    bool isMainAppConnected,
  }) = FloatyScopeData._;

  const FloatyScopeData._({
    this.lastMessage,
    this.lastTappedId,
    this.lastClosedId,
    this.lastExpandedId,
    this.lastCollapsedId,
    this.lastDragStart,
    this.lastDragEnd,
    this.palette,
    this.messages = const [],
    this.isMainAppConnected = true,
  });

  /// The most recent data message from the main app, or `null`.
  final Object? lastMessage;

  /// All data messages received from the main app, in order.
  final List<Object?> messages;

  /// The ID of the chathead that was most recently tapped, or `null`.
  final String? lastTappedId;

  /// The ID of the chathead that was most recently closed, or `null`.
  final String? lastClosedId;

  /// The ID of the chathead whose panel was most recently expanded.
  final String? lastExpandedId;

  /// The ID of the chathead whose panel was most recently collapsed.
  final String? lastCollapsedId;

  /// The most recent drag-start event, or `null`.
  final ChatHeadDragEvent? lastDragStart;

  /// The most recent drag-end event, or `null`.
  final ChatHeadDragEvent? lastDragEnd;

  /// The current overlay color palette, or `null` if none was sent.
  final OverlayColorPalette? palette;

  /// Whether the main app is currently connected to the overlay; `false`
  /// when it has been killed or backgrounded.
  final bool isMainAppConnected;
}
