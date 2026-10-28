import 'package:floaty_chatheads/src/floaty_controller.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

part 'floaty_controller_widget_state.dart';

/// A declarative widget that shows the chathead when mounted and closes
/// it when unmounted.
///
/// Provide [child], or [builder] to rebuild with the [FloatyController]
/// whenever it notifies. Descendants reach the controller through
/// [FloatyControllerWidget.of].
final class FloatyControllerWidget extends StatefulWidget {
  /// Creates the widget; either [child] or [builder] must be provided.
  const factory FloatyControllerWidget({
    Widget? child,
    Widget Function(BuildContext context, FloatyController controller)? builder,
    Key? key,
    String entryPoint,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    bool debugMode,
    void Function(Object? data)? onData,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
  }) = FloatyControllerWidget._;

  const FloatyControllerWidget._({
    this.child,
    this.builder,
    super.key,
    this.entryPoint = 'overlayMain',
    this.sizePreset,
    this.theme,
    this.debugMode = false,
    this.onData,
    this.assets,
    this.notification,
    this.snap,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided.',
       );

  /// The widget to render while the chathead is active.
  final Widget? child;

  /// Builder that receives the [FloatyController] directly, rebuilt when
  /// the controller notifies.
  final Widget Function(BuildContext context, FloatyController controller)?
  builder;

  /// Dart entry-point function name for the overlay.
  final String entryPoint;

  /// Named size preset.
  final ContentSizePreset? sizePreset;

  /// Theming configuration.
  final ChatHeadTheme? theme;

  /// Whether to enable the native debug inspector.
  final bool debugMode;

  /// Callback when data arrives from the overlay.
  final void Function(Object? data)? onData;

  /// Grouped asset configuration.
  final ChatHeadAssets? assets;

  /// Grouped notification configuration.
  final NotificationConfig? notification;

  /// Grouped snap-behavior configuration.
  final SnapConfig? snap;

  /// Returns the nearest [FloatyController] above [context], or `null`.
  static FloatyController? of(BuildContext context) => context
      .findAncestorStateOfType<_FloatyControllerWidgetState>()
      ?._controller;

  @override
  State<FloatyControllerWidget> createState() => _FloatyControllerWidgetState();
}
