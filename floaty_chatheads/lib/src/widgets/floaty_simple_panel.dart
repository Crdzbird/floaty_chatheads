import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:flutter/material.dart';

/// {@template floaty_simple_panel}
/// A pre-built styled container for the overlay side.
///
/// Wraps your content in a Material card with optional title and a
/// close button that dismisses the overlay via
/// [FloatyOverlay.closeOverlay]. Use it from inside an overlay entry
/// point to skip the Card/Material/Padding boilerplate:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(
///   const FloatySimplePanel(
///     title: 'Notifications',
///     child: Text('You have 3 new messages'),
///   ),
/// );
/// ```
///
/// All parameters are optional except [child]. Set [showCloseButton]
/// to `false` to hide the close icon, or pass [onClose] to override
/// the default dismiss behavior.
///
/// For richer pre-built overlays see [FloatyMiniPlayer] and
/// [FloatyNotificationCard].
/// {@endtemplate}
class FloatySimplePanel extends StatelessWidget {
  /// {@macro floaty_simple_panel}
  const FloatySimplePanel({
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

  /// Whether to render a close icon when [title] or [onClose] is set.
  ///
  /// Defaults to `true`. Setting this to `false` produces a header
  /// with only the [title] (or no header at all if [title] is null).
  final bool showCloseButton;

  /// Called when the close icon is tapped. Defaults to
  /// [FloatyOverlay.closeOverlay].
  final VoidCallback? onClose;

  bool get _hasHeader => title != null || showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: elevation,
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasHeader) _PanelHeader(
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
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.showCloseButton,
    required this.onClose,
  });

  final String? title;
  final bool showCloseButton;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4, top: 4),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close overlay',
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
