import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders [widget] into a [ui.Image] via an offscreen pipeline.
///
/// The widget is laid out in a [size] x [size] logical-pixel box inside a
/// dedicated `RenderView`, `PipelineOwner` and `BuildOwner`, so the main
/// widget tree's frame budget is untouched. Rasterisation runs on the
/// engine's raster thread.
Future<ui.Image> renderWidgetToImage(
  Widget widget, {
  required double size,
  double pixelRatio = 3.0,
}) async {
  final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  if (view == null) {
    throw StateError(
      'widgetToIconSource requires an implicit FlutterView. '
      'Ensure WidgetsFlutterBinding is initialised.',
    );
  }
  final box = BoxConstraints.tight(Size(size, size));
  final repaintBoundary = RenderRepaintBoundary();
  final renderView =
      RenderView(
          view: view,
          child: RenderPositionedBox(
            child: RenderConstrainedBox(
              additionalConstraints: box,
              child: repaintBoundary,
            ),
          ),
        )
        ..configuration = ViewConfiguration(
          logicalConstraints: box,
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
        child: MediaQuery(data: MediaQueryData.fromView(view), child: widget),
      ),
    ),
  ).attachToRenderTree(buildOwner);
  try {
    buildOwner.buildScope(rootElement);
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();
    return await repaintBoundary.toImage(pixelRatio: pixelRatio);
  } finally {
    buildOwner.finalizeTree();
    focusManager.dispose();
  }
}
