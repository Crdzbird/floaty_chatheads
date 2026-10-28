import 'dart:async';

import 'package:floaty_chatheads/src/generated/floaty_chatheads_overlay_api.g.dart';
import 'package:floaty_chatheads/src/overlay/chat_head_drag_event.dart';

/// Receives the native overlay callbacks and fans them out as broadcast
/// streams for `FloatyOverlay`.
final class FloatyOverlayEvents implements FloatyOverlayFlutterApi {
  FloatyOverlayEvents._();

  /// The single instance registered with the Pigeon API.
  static final FloatyOverlayEvents instance = FloatyOverlayEvents._();

  /// Emits the ID of each tapped chathead.
  final StreamController<String> tapped = StreamController.broadcast();

  /// Emits the ID of each closed chathead.
  final StreamController<String> closed = StreamController.broadcast();

  /// Emits the ID when the content panel expands.
  final StreamController<String> expanded = StreamController.broadcast();

  /// Emits the ID when the content panel collapses.
  final StreamController<String> collapsed = StreamController.broadcast();

  /// Emits drag-start events.
  final StreamController<ChatHeadDragEvent> dragStart =
      StreamController.broadcast();

  /// Emits drag-end events.
  final StreamController<ChatHeadDragEvent> dragEnd =
      StreamController.broadcast();

  @override
  Future<void> onChatHeadTapped(String id) async => tapped.add(id);

  @override
  Future<void> onChatHeadClosed(String id) async => closed.add(id);

  @override
  Future<void> onChatHeadExpanded(String id) async => expanded.add(id);

  @override
  Future<void> onChatHeadCollapsed(String id) async => collapsed.add(id);

  @override
  Future<void> onChatHeadDragStart(String id, double x, double y) async =>
      dragStart.add(ChatHeadDragEvent(id: id, x: x, y: y));

  @override
  Future<void> onChatHeadDragEnd(String id, double x, double y) async =>
      dragEnd.add(ChatHeadDragEvent(id: id, x: x, y: y));
}
