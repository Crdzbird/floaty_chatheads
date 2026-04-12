import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Test-only override for [ui.Image.toByteData].
///
/// The Flutter test harness cannot extract bytes from rasterised images
/// because the engine's raster thread is not available. Set this in
/// `setUp` to return synthetic [ByteData] so that all code paths through
/// [renderWidgetToPngByteData], [renderWidgetToRgbaByteData],
/// [renderWidgetToBytes], and [widgetToIconSource] can be exercised.
///
/// ```dart
/// setUp(() {
///   testImageEncoder = (image, format) async =>
///       ByteData(image.width * image.height * 4);
/// });
/// tearDown(() => testImageEncoder = null);
/// ```
@visibleForTesting
Future<ByteData> Function(ui.Image image, ui.ImageByteFormat format)?
    testImageEncoder;

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
    // coverage:ignore-start
    throw StateError(
      'widgetToIconSource requires an implicit FlutterView. '
      'Ensure WidgetsFlutterBinding is initialised.',
    );
    // coverage:ignore-end
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

  final focusManager = FocusManager();
  final buildOwner = BuildOwner(focusManager: focusManager);
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

  try {
    buildOwner.buildScope(rootElement);
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    // toImage runs on the raster thread — does not block the UI thread.
    return await repaintBoundary.toImage(pixelRatio: pixelRatio);
  } finally {
    buildOwner.finalizeTree();
    focusManager.dispose();
  }
}

/// Extracts bytes from [image] in the given [format].
///
/// Delegates to [testImageEncoder] when set (test environment) or
/// falls back to the engine's `toByteData` (production).
Future<ByteData> _encodeImage(
  ui.Image image,
  ui.ImageByteFormat format,
) async {
  if (testImageEncoder != null) {
    return testImageEncoder!(image, format);
  }
  return (await image.toByteData(format: format))!; // coverage:ignore-line
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
  final byteData = await _encodeImage(image, ui.ImageByteFormat.rawRgba);
  final w = image.width;
  final h = image.height;
  image.dispose();
  return (bytes: byteData, width: w, height: h);
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
