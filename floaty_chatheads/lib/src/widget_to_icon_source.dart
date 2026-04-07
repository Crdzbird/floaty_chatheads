import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders any [Widget] tree into an [IconSource] suitable for chathead icons.
///
/// The widget is laid out in a [size] x [size] logical-pixel box and
/// rasterised at [pixelRatio] (defaults to 3.0 for crisp icons on
/// high-DPI displays).
///
/// The rendering happens in an **offscreen pipeline** — a dedicated
/// `RenderView` + `PipelineOwner` + `BuildOwner` that is independent of
/// the main widget tree, so it does not block the app's frame budget.
/// The GPU rasterisation (`toImage`) and byte encoding are async and
/// execute on the engine's raster thread.
///
/// Works with any widget: [Text], [Icon], [Container], `CircleAvatar`,
/// custom paint, etc.
///
/// ```dart
/// final icon = await widgetToIconSource(
///   const CircleAvatar(child: Text('JD')),
///   size: 80,
/// );
/// ```
Future<IconSource> widgetToIconSource(
  Widget widget, {
  double size = 80,
  double pixelRatio = 3.0,
}) async {
  final bytes =
      await renderWidgetToBytes(widget, size: size, pixelRatio: pixelRatio);
  return IconSource.bytes(bytes);
}

/// Renders [widget] into a [ui.Image] via the offscreen pipeline.
Future<ui.Image> renderWidgetToImage(
  Widget widget, {
  required double size,
  double pixelRatio = 3.0,
}) async {
  final repaintBoundary = RenderRepaintBoundary();

  final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  if (view == null) {
    throw StateError(
      'widgetToIconSource requires an implicit FlutterView. '
      'Ensure WidgetsFlutterBinding is initialised.',
    );
  }

  final renderView = RenderView(
    view: view,
    child: RenderPositionedBox(
      child: RenderConstrainedBox(
        additionalConstraints: BoxConstraints.tight(Size(size, size)),
        child: repaintBoundary,
      ),
    ),
  )..configuration = ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(Size(size, size)),
      devicePixelRatio: pixelRatio,
    );

  final pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Theme(
      data: ThemeData.light(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData.fromView(view),
          child: widget,
        ),
      ),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  // toImage runs on the raster thread — does not block the UI thread.
  final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);

  buildOwner.finalizeTree();

  return image;
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
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!;
}

/// Renders [widget] to raw RGBA bytes (no PNG encoding overhead).
///
/// Returns a record of `(bytes, pixelWidth, pixelHeight)` ready for
/// `FloatyChatheadsPlatform.updateChatHeadIcon`.
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
  final byteData =
      await image.toByteData();
  final w = image.width;
  final h = image.height;
  image.dispose();
  return (bytes: byteData!, width: w, height: h);
}

/// Convenience: renders to PNG [Uint8List].
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
