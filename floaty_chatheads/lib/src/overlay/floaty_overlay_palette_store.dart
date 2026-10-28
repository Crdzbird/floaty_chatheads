part of '../floaty_overlay.dart';

/// Holds the latest [OverlayColorPalette] delivered on the theme prefix.
final class _PaletteStore {
  static const _prefix = '_floaty_theme';

  static final StreamController<OverlayColorPalette> _controller =
      StreamController<OverlayColorPalette>.broadcast();

  static OverlayColorPalette? _current;

  static void _attach() => FloatyChannel.registerHandler(_prefix, _onMessage);

  static void _detach() => FloatyChannel.unregisterHandler(_prefix);

  static void _onMessage(Map<String, dynamic> data) {
    final palette = OverlayColorPalette._fromMap(
      data.map((k, v) => MapEntry(k, v as int)),
    );
    _current = palette;
    _controller.add(palette);
  }
}
