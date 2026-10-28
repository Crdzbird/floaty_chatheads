import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floaty_chatheads/src/icons/render_widget_to_image.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

export 'package:floaty_chatheads/src/icons/render_widget_to_image.dart';

/// Test-only override for [ui.Image.toByteData].
///
/// The Flutter test harness cannot extract bytes from rasterised images,
/// so set this in `setUp` to return synthetic [ByteData] and exercise
/// every render helper; reset it to `null` in `tearDown`.
@visibleForTesting
Future<ByteData> Function(ui.Image image, ui.ImageByteFormat format)?
testImageEncoder;

/// Renders any [Widget] tree into an [IconSource] suitable for chathead
/// icons, e.g. `await widgetToIconSource(const CircleAvatar(), size: 80)`.
///
/// The widget is laid out in a [size] x [size] box and rasterised at
/// [pixelRatio] through the offscreen pipeline of [renderWidgetToImage].
Future<IconSource> widgetToIconSource(
  Widget widget, {
  double size = 80,
  double pixelRatio = 3.0,
}) async => IconSource.bytes(
  await renderWidgetToBytes(widget, size: size, pixelRatio: pixelRatio),
);

Future<ByteData> _encodeImage(ui.Image image, ui.ImageByteFormat format) async {
  final encoder = testImageEncoder;
  if (encoder != null) return await encoder(image, format);
  return (await image.toByteData(format: format))!;
}

/// Renders [widget] to PNG-encoded [ByteData] via the offscreen pipeline.
Future<ByteData> renderWidgetToPngByteData(
  Widget widget, {
  required double size,
  double pixelRatio = 3.0,
}) async {
  final image = await renderWidgetToImage(
    widget,
    size: size,
    pixelRatio: pixelRatio,
  );
  final byteData = await _encodeImage(image, ui.ImageByteFormat.png);
  image.dispose();
  return byteData;
}

/// Renders [widget] to raw RGBA bytes (no PNG encoding overhead), ready
/// for `FloatyChatheadsPlatform.updateChatHeadIcon`.
Future<({ByteData bytes, int width, int height})> renderWidgetToRgbaByteData(
  Widget widget, {
  required double size,
  double pixelRatio = 3.0,
}) async {
  final image = await renderWidgetToImage(
    widget,
    size: size,
    pixelRatio: pixelRatio,
  );
  final byteData = await _encodeImage(image, ui.ImageByteFormat.rawRgba);
  final width = image.width;
  final height = image.height;
  image.dispose();
  return (bytes: byteData, width: width, height: height);
}

/// Renders [widget] to a PNG [Uint8List].
Future<Uint8List> renderWidgetToBytes(
  Widget widget, {
  required double size,
  double pixelRatio = 3.0,
}) async {
  final byteData = await renderWidgetToPngByteData(
    widget,
    size: size,
    pixelRatio: pixelRatio,
  );
  return byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
}
