import 'dart:typed_data';

import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Renders animation frames to raw RGBA bytes and pushes them to the
/// native icon of one chathead, dropping frames while one is in flight.
final class IconFrameSender {
  /// Creates a sender for chathead [id] rendering at [size] and
  /// [pixelRatio].
  factory IconFrameSender({
    required String id,
    required double size,
    required double pixelRatio,
  }) = IconFrameSender._;

  IconFrameSender._({
    required this.id,
    required this.size,
    required this.pixelRatio,
  });

  /// Target chathead ID.
  final String id;

  /// Logical icon size.
  final double size;

  /// Rasterisation pixel ratio.
  final double pixelRatio;

  bool _busy = false;

  /// Builds a frame with [frame] and sends it, unless the previous frame
  /// is still being sent.
  Future<void> send(Widget Function() frame) async {
    if (_busy) return;
    _busy = true;
    try {
      final rgba = await renderWidgetToRgbaByteData(
        frame(),
        size: size,
        pixelRatio: pixelRatio,
      );
      final bytes = rgba.bytes;
      await FloatyChatheadsPlatform.instance.updateChatHeadIcon(
        id,
        Uint8List.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes),
        rgba.width,
        rgba.height,
      );
    } finally {
      _busy = false;
    }
  }
}
