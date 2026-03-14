import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Overlay that demonstrates consuming the theme palette sent from the main app.
///
/// Uses [FloatyOverlay.palette] and [FloatyOverlay.onPaletteChanged] to apply
/// host-defined colors to the overlay UI.
class ThemedOverlay extends StatefulWidget {
  const ThemedOverlay({super.key});

  @override
  State<ThemedOverlay> createState() => _ThemedOverlayState();
}

class _ThemedOverlayState extends State<ThemedOverlay> {
  OverlayColorPalette? _palette;
  StreamSubscription<OverlayColorPalette>? _paletteSub;
  StreamSubscription<Object?>? _dataSub;
  String _lastMessage = 'Waiting for data...';

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    // Read initial palette if already available.
    _palette = FloatyOverlay.palette;

    // Listen for palette changes.
    _paletteSub = FloatyOverlay.onPaletteChanged.listen((p) {
      if (mounted) setState(() => _palette = p);
    });

    // Listen for data from the main app.
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (mounted) setState(() => _lastMessage = '$data');
    });
  }

  Color get _primary => _palette?.primary ?? const Color(0xFF6200EE);
  Color get _surface => _palette?.surface ?? Colors.white;
  Color get _onPrimary => _palette?.onPrimary ?? Colors.white;
  Color get _onSurface => _palette?.onSurface ?? Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'Themed Overlay',
                  style: TextStyle(
                    color: _onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _palette != null
                          ? 'Palette received!'
                          : 'No palette yet',
                      style: TextStyle(color: _onSurface, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    // Color swatch preview
                    if (_palette != null)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _swatch('P', _palette!.primary),
                          _swatch('S', _palette!.secondary),
                          _swatch('Sf', _palette!.surface),
                          _swatch('Bg', _palette!.background),
                          _swatch('E', _palette!.error),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _lastMessage,
                        style: TextStyle(
                          color: _onSurface,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        FloatyOverlay.shareData({
                          'from': 'themed_overlay',
                          'palette_received': _palette != null,
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Send to Main',
                          style: TextStyle(
                            color: _onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: _onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swatch(String label, Color? color) {
    final c = color ?? Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  @override
  void dispose() {
    _paletteSub?.cancel();
    _dataSub?.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
