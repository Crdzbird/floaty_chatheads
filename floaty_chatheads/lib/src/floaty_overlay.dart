import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';
import 'package:floaty_chatheads/src/generated/floaty_chatheads_overlay_api.g.dart';
import 'package:floaty_chatheads/src/overlay/chat_head_drag_event.dart';
import 'package:floaty_chatheads/src/overlay/floaty_overlay_events.dart';
import 'package:floaty_chatheads/src/overlay/floaty_overlay_host.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart'
    show OverlayFlag, OverlayPosition;
import 'package:flutter/services.dart';

export 'package:floaty_chatheads/src/overlay/chat_head_drag_event.dart';

part 'overlay/floaty_overlay_palette_store.dart';
part 'overlay/overlay_color_palette.dart';

/// Overlay-side API for talking to the main app. Call [setUp] once in the
/// overlay entry point, or use `FloatyOverlayApp.run`, which does it.
final class FloatyOverlay {
  FloatyOverlay._();

  static final FloatyOverlayEvents _events = FloatyOverlayEvents.instance;
  static final FloatyOverlayHostApi _hostApi = FloatyOverlayHost.api;
  static bool _isSetUp = false;

  /// Registers the overlay callbacks. Safe to call more than once.
  static void setUp() {
    if (_isSetUp) return;
    FloatyOverlayFlutterApi.setUp(_events);
    _PaletteStore._attach();
    FloatyConnectionState.setUp();
    FloatyChannel.ensureListening();
    _isSetUp = true;
  }

  /// Stream of messages sent from the main app.
  static Stream<Object?> get onData => FloatyChannel.rawMessages;

  /// Emits the ID of the chathead bubble that was tapped.
  static Stream<String> get onTapped => _events.tapped.stream;

  /// Emits the ID of the chathead that was closed.
  static Stream<String> get onClosed => _events.closed.stream;

  /// Emits the ID when the chathead content panel is expanded.
  static Stream<String> get onExpanded => _events.expanded.stream;

  /// Emits the ID when the chathead content panel is collapsed.
  static Stream<String> get onCollapsed => _events.collapsed.stream;

  /// Emits a [ChatHeadDragEvent] when the user starts dragging a chathead.
  static Stream<ChatHeadDragEvent> get onDragStart => _events.dragStart.stream;

  /// Emits a [ChatHeadDragEvent] when the user stops dragging a chathead.
  static Stream<ChatHeadDragEvent> get onDragEnd => _events.dragEnd.stream;

  /// The palette set by the main app, or `null` when `ChatHeadTheme` has
  /// none.
  static OverlayColorPalette? get palette => _PaletteStore._current;

  /// Emits whenever the overlay palette changes.
  static Stream<OverlayColorPalette> get onPaletteChanged =>
      _PaletteStore._controller.stream;

  /// {@macro floaty_chatheads_platform.resize_content}
  static Future<void> resizeContent(int width, int height) =>
      _hostApi.resizeContent(width, height);

  /// {@macro floaty_chatheads_platform.update_flag}
  static Future<void> updateFlag(OverlayFlag flag) =>
      _hostApi.updateFlag(flag.index);

  /// {@macro floaty_chatheads_platform.close_overlay}
  static Future<void> closeOverlay() => _hostApi.closeOverlay();

  /// {@macro floaty_chatheads_platform.get_overlay_position}
  static Future<OverlayPosition> getOverlayPosition() =>
      FloatyOverlayHost.position();

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) =>
      _hostApi.updateBadgeFromOverlay(count);

  /// Debug information from the native side (spring state, visibility,
  /// Pigeon log); only populated when `debugMode` is enabled.
  static Future<Map<String, Object?>> getDebugInfo() =>
      FloatyOverlayHost.debugInfo();

  /// Sends data from the overlay to the main app over a
  /// [BasicMessageChannel] with [JSONMessageCodec].
  static Future<void> shareData(Object? data) => FloatyChannel.send(data);

  /// Detaches the palette handler; [setUp] can attach everything again.
  static void dispose() {
    _PaletteStore._detach();
    _isSetUp = false;
  }
}
