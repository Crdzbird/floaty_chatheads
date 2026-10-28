import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

part 'panel/floaty_panel_header.dart';

/// A pre-built styled container for the overlay side.
///
/// Wraps your content in a Material card with an optional title and a
/// close button that calls [FloatyOverlay.closeOverlay]:
///
/// ```dart
/// FloatyOverlayApp.run(
///   const FloatySimplePanel(title: 'Inbox', child: Text('3 new messages')),
/// );
/// ```
///
/// For richer pre-built overlays see [FloatyMiniPlayer] and
/// [FloatyNotificationCard].
final class FloatySimplePanel extends StatelessWidget {
  /// Creates a panel around [child].
  const factory FloatySimplePanel({
    required Widget child,
    Key? key,
    String? title,
    EdgeInsetsGeometry padding,
    double elevation,
    BorderRadius borderRadius,
    Color? backgroundColor,
    bool showCloseButton,
    VoidCallback? onClose,
  }) = FloatySimplePanel._;

  const FloatySimplePanel._({
    required this.child,
    super.key,
    this.title,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor,
    this.showCloseButton = true,
    this.onClose,
  });

  /// Content rendered inside the panel.
  final Widget child;

  /// Optional title shown in a header row above [child].
  final String? title;

  /// Inset around [child]. Defaults to 16 dp on all sides.
  final EdgeInsetsGeometry padding;

  /// Card shadow elevation. Defaults to 8.
  final double elevation;

  /// Corner radius of the card.
  final BorderRadius borderRadius;

  /// Card background color. Defaults to the theme's `cardColor`.
  final Color? backgroundColor;

  /// Whether to render the close icon. Defaults to `true`; with `false`
  /// the header shows only the [title], or nothing when it is null.
  final bool showCloseButton;

  /// Called when the close icon is tapped. Defaults to
  /// [FloatyOverlay.closeOverlay].
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Card(
      margin: EdgeInsets.zero,
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || showCloseButton)
            _PanelHeader(
              title: title,
              showCloseButton: showCloseButton,
              onClose: onClose ?? FloatyOverlay.closeOverlay,
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    ),
  );
}
