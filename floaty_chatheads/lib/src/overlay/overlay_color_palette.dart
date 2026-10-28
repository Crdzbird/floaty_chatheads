part of '../floaty_overlay.dart';

/// Color palette sent from the main app to the overlay isolate.
///
/// Populated from `ChatHeadTheme.overlayPalette` and delivered when the
/// overlay engine starts, so the overlay UI can match the app's theme:
/// `FloatyOverlay.palette?.primary` or `FloatyOverlay.palette?['custom']`.
final class OverlayColorPalette {
  OverlayColorPalette._({required this._colors});

  factory OverlayColorPalette._fromMap(Map<String, int> map) =>
      OverlayColorPalette._(colors: Map.unmodifiable(map));

  final Map<String, int> _colors;

  /// The primary brand color.
  Color? get primary => _colorFor('primary');

  /// The secondary brand color.
  Color? get secondary => _colorFor('secondary');

  /// The surface color for cards and panels.
  Color? get surface => _colorFor('surface');

  /// The background color.
  Color? get background => _colorFor('background');

  /// Text and icon color on primary.
  Color? get onPrimary => _colorFor('onPrimary');

  /// Text and icon color on secondary.
  Color? get onSecondary => _colorFor('onSecondary');

  /// Text and icon color on surface.
  Color? get onSurface => _colorFor('onSurface');

  /// The error color.
  Color? get error => _colorFor('error');

  /// Text and icon color on error.
  Color? get onError => _colorFor('onError');

  /// Retrieves a color by key name, or `null` when the key is absent.
  Color? operator [](String key) => _colorFor(key);

  Color? _colorFor(String key) {
    final value = _colors[key];
    return value != null ? Color(value) : null;
  }

  @override
  String toString() => 'OverlayColorPalette($_colors)';
}
