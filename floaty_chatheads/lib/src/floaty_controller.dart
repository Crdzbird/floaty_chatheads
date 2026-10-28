import 'dart:async';

import 'package:floaty_chatheads/src/floaty.dart';
import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

export 'package:floaty_chatheads/src/controller/floaty_controller_widget.dart';

part 'controller/floaty_controller_behavior.dart';
part 'controller/floaty_controller_options.dart';

/// A [ChangeNotifier] that shows and closes the chathead for a widget's
/// lifecycle. Create it in `initState` (with `autoShow: true` to show
/// right away) and dispose it in `dispose`, or let
/// `FloatyControllerWidget` manage it.
final class FloatyController extends _FloatyControllerOptions
    with _FloatyControllerBehavior {
  /// Creates a controller; [autoShow] shows the chathead immediately.
  factory FloatyController({
    String entryPoint,
    String? entryPointLibrary,
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag,
    bool enableDrag,
    EntranceAnimation entranceAnimation,
    PanelAnchor panelAnchor,
    bool autoLaunchOnBackground,
    bool persistOnAppClose,
    bool debugMode,
    bool autoShow,
    void Function(Object? data)? onData,
    void Function(Object error, StackTrace stack)? onError,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
  }) = FloatyController._;

  FloatyController._({
    super.entryPoint,
    super.entryPointLibrary,
    super.contentWidth,
    super.contentHeight,
    super.sizePreset,
    super.theme,
    super.flag,
    super.enableDrag,
    super.entranceAnimation,
    super.panelAnchor,
    super.autoLaunchOnBackground,
    super.persistOnAppClose,
    super.debugMode,
    bool autoShow = false,
    super.onData,
    super.onError,
    super.assets,
    super.notification,
    super.snap,
  }) {
    if (autoShow) unawaited(show());
  }
}
