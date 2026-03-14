import 'dart:async';

import 'package:floaty_chatheads/src/generated/floaty_chatheads_overlay_api.g.dart';
import 'package:flutter/services.dart';

/// {@template floaty_overlay}
/// Overlay-side API for communicating from inside the overlay back
/// to the main app.
///
/// Use this within the Dart entry point function (e.g. `overlayMain`)
/// that runs in the overlay isolate.
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() {
///   WidgetsFlutterBinding.ensureInitialized();
///   FloatyOverlay.setUp();
///   runApp(const MyOverlayApp());
/// }
/// ```
/// {@endtemplate}
final class FloatyOverlay implements FloatyOverlayFlutterApi {
  FloatyOverlay._(); // coverage:ignore-line

  static final FloatyOverlay _instance = FloatyOverlay._(); // coverage:ignore-line

  static final FloatyOverlayHostApi _overlayHostApi = FloatyOverlayHostApi(); // coverage:ignore-line

  static const BasicMessageChannel<Object?> _messenger =
      BasicMessageChannel<Object?>(
        'ni.devotion.floaty_head/messenger',
        JSONMessageCodec(),
      );

  static final StreamController<Object?> _dataController =
      StreamController<Object?>.broadcast();

  static final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  static final StreamController<String> _closeController =
      StreamController<String>.broadcast();

  static final StreamController<String> _expandController =
      StreamController<String>.broadcast();

  static final StreamController<String> _collapseController =
      StreamController<String>.broadcast();

  static final StreamController<ChatHeadDragEvent> _dragStartController =
      StreamController<ChatHeadDragEvent>.broadcast();

  static final StreamController<ChatHeadDragEvent> _dragEndController =
      StreamController<ChatHeadDragEvent>.broadcast();

  static final StreamController<OverlayColorPalette> _paletteController =
      StreamController<OverlayColorPalette>.broadcast();

  static bool _isSetUp = false;

  /// The current overlay color palette, if one was sent by the main app.
  static OverlayColorPalette? _palette;

  /// {@template floaty_overlay.set_up}
  /// Call once in your overlay entry point to set up the Flutter API handler.
  ///
  /// Registers the Pigeon callback handlers and the message-channel
  /// listener for data and palette messages.
  /// {@endtemplate}
  static void setUp() {
    if (!_isSetUp) {
      FloatyOverlayFlutterApi.setUp(_instance);
      _messenger.setMessageHandler((message) async {
        // Intercept theme palette messages from native.
        if (message is Map && message.containsKey('_floaty_theme')) {
          final raw = message['_floaty_theme'];
          if (raw is Map) {
            final palette = OverlayColorPalette._fromMap(
              raw.map((k, v) => MapEntry(k.toString(), v as int)),
            );
            _palette = palette;
            _paletteController.add(palette);
            return message;
          }
        }
        _dataController.add(message);
        return message;
      });
      _isSetUp = true;
    }
  }

  /// {@template floaty_overlay.on_data}
  /// Stream of messages sent from the main app.
  /// {@endtemplate}
  static Stream<Object?> get onData => _dataController.stream;

  /// {@template floaty_overlay.on_tapped}
  /// Stream that emits the ID of the chathead bubble that was tapped.
  /// {@endtemplate}
  static Stream<String> get onTapped => _tapController.stream;

  /// {@template floaty_overlay.on_closed}
  /// Stream that emits the ID of the chathead that was closed.
  /// {@endtemplate}
  static Stream<String> get onClosed => _closeController.stream;

  /// {@template floaty_overlay.on_expanded}
  /// Stream that emits the ID when the chathead content panel is expanded.
  /// {@endtemplate}
  static Stream<String> get onExpanded => _expandController.stream;

  /// {@template floaty_overlay.on_collapsed}
  /// Stream that emits the ID when the chathead content panel is collapsed.
  /// {@endtemplate}
  static Stream<String> get onCollapsed => _collapseController.stream;

  /// {@template floaty_overlay.on_drag_start}
  /// Stream that emits a [ChatHeadDragEvent] when the user starts dragging
  /// a chathead.
  /// {@endtemplate}
  static Stream<ChatHeadDragEvent> get onDragStart =>
      _dragStartController.stream;

  /// {@template floaty_overlay.on_drag_end}
  /// Stream that emits a [ChatHeadDragEvent] when the user stops dragging
  /// a chathead.
  /// {@endtemplate}
  static Stream<ChatHeadDragEvent> get onDragEnd => _dragEndController.stream;

  /// {@template floaty_overlay.palette}
  /// The current overlay color palette set by the main app.
  ///
  /// Returns `null` if no palette was configured via `ChatHeadTheme`.
  /// {@endtemplate}
  static OverlayColorPalette? get palette => _palette;

  /// {@template floaty_overlay.on_palette_changed}
  /// Stream that emits whenever the overlay palette changes.
  /// {@endtemplate}
  static Stream<OverlayColorPalette> get onPaletteChanged =>
      _paletteController.stream;

  // coverage:ignore-start

  /// {@macro floaty_chatheads_platform.resize_content}
  static Future<void> resizeContent(int width, int height) =>
      _overlayHostApi.resizeContent(width, height);

  /// {@macro floaty_chatheads_platform.update_flag}
  static Future<void> updateFlag(OverlayFlagMessage flag) =>
      _overlayHostApi.updateFlag(flag);

  /// {@macro floaty_chatheads_platform.close_overlay}
  static Future<void> closeOverlay() => _overlayHostApi.closeOverlay();

  /// {@macro floaty_chatheads_platform.get_overlay_position}
  static Future<OverlayPositionMessage> getOverlayPosition() =>
      _overlayHostApi.getOverlayPosition();

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) =>
      _overlayHostApi.updateBadgeFromOverlay(count);

  /// {@template floaty_overlay.get_debug_info}
  /// Retrieves debug information from the native side.
  ///
  /// Only populated when `debugMode` is enabled in `ChatHeadConfig`.
  /// Returns spring state, visibility, toggle state, and Pigeon message log.
  /// {@endtemplate}
  static Future<Map<String, Object?>> getDebugInfo() async {
    final raw = await _overlayHostApi.getDebugInfo();
    return raw.map((k, v) => MapEntry(k?.toString() ?? '', v));
  }

  /// {@template floaty_overlay.share_data}
  /// Sends data from the overlay to the main app.
  ///
  /// The data is serialized via [JSONMessageCodec] and forwarded
  /// through a [BasicMessageChannel].
  /// {@endtemplate}
  static Future<void> shareData(Object? data) => _messenger.send(data);

  // coverage:ignore-end

  /// {@template floaty_overlay.dispose}
  /// Detaches the message handler and Pigeon API.
  ///
  /// Safe to call multiple times. After calling, [setUp] can be
  /// called again to re-attach handlers.
  /// {@endtemplate}
  static void dispose() {
    _messenger.setMessageHandler(null);
    _isSetUp = false;
  }

  // FloatyOverlayFlutterApi implementation
  @override
  void onChatHeadTapped(String id) => _tapController.add(id);

  @override
  void onChatHeadClosed(String id) => _closeController.add(id);

  @override
  void onChatHeadExpanded(String id) => _expandController.add(id);

  @override
  void onChatHeadCollapsed(String id) => _collapseController.add(id);

  @override
  void onChatHeadDragStart(String id, double x, double y) =>
      _dragStartController.add(ChatHeadDragEvent(id: id, x: x, y: y));

  @override
  void onChatHeadDragEnd(String id, double x, double y) =>
      _dragEndController.add(ChatHeadDragEvent(id: id, x: x, y: y));
}

/// {@template chat_head_drag_event}
/// Event emitted when a chathead drag starts or ends.
///
/// Contains the chathead [id] and its position ([x], [y]) in physical pixels.
/// {@endtemplate}
class ChatHeadDragEvent {
  /// {@macro chat_head_drag_event}
  const ChatHeadDragEvent({
    required this.id,
    required this.x,
    required this.y,
  });

  /// The ID of the chathead being dragged.
  final String id;

  /// The X position of the chathead (in physical pixels).
  final double x;

  /// The Y position of the chathead (in physical pixels).
  final double y;

  @override
  String toString() => 'ChatHeadDragEvent(id: $id, x: $x, y: $y)';
}

/// {@template overlay_color_palette}
/// Color palette sent from the main app to the overlay isolate.
///
/// Use this to style your overlay's Flutter UI to match the main app's theme.
/// The palette is populated from the `ChatHeadTheme.overlayPalette` map and
/// delivered automatically when the overlay engine starts.
///
/// Access individual colors by name:
/// ```dart
/// final primary = FloatyOverlay.palette?.primary;
/// final custom = FloatyOverlay.palette?['myCustomKey'];
/// ```
/// {@endtemplate}
class OverlayColorPalette {
  OverlayColorPalette._({required Map<String, int> colors}) : _colors = colors;

  factory OverlayColorPalette._fromMap(Map<String, int> map) {
    return OverlayColorPalette._(colors: Map.unmodifiable(map));
  }

  final Map<String, int> _colors;

  /// {@template overlay_color_palette.primary}
  /// The primary brand color.
  /// {@endtemplate}
  Color? get primary => _colorFor('primary');

  /// {@template overlay_color_palette.secondary}
  /// The secondary brand color.
  /// {@endtemplate}
  Color? get secondary => _colorFor('secondary');

  /// {@template overlay_color_palette.surface}
  /// The surface color for cards and panels.
  /// {@endtemplate}
  Color? get surface => _colorFor('surface');

  /// {@template overlay_color_palette.background}
  /// The background color.
  /// {@endtemplate}
  Color? get background => _colorFor('background');

  /// {@template overlay_color_palette.on_primary}
  /// Text/icon color on primary.
  /// {@endtemplate}
  Color? get onPrimary => _colorFor('onPrimary');

  /// {@template overlay_color_palette.on_secondary}
  /// Text/icon color on secondary.
  /// {@endtemplate}
  Color? get onSecondary => _colorFor('onSecondary');

  /// {@template overlay_color_palette.on_surface}
  /// Text/icon color on surface.
  /// {@endtemplate}
  Color? get onSurface => _colorFor('onSurface');

  /// {@template overlay_color_palette.error}
  /// The error color.
  /// {@endtemplate}
  Color? get error => _colorFor('error');

  /// {@template overlay_color_palette.on_error}
  /// Text/icon color on error.
  /// {@endtemplate}
  Color? get onError => _colorFor('onError');

  /// Retrieves a color by key name.
  ///
  /// Returns `null` if the key is not present in the palette.
  Color? operator [](String key) => _colorFor(key);

  Color? _colorFor(String key) {
    final value = _colors[key];
    return value != null ? Color(value) : null;
  }

  @override
  String toString() => 'OverlayColorPalette($_colors)';
}
