import 'dart:async';

import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_scope}
/// An [InheritedWidget] that automatically subscribes to all
/// [FloatyOverlay] streams and exposes them to descendant widgets.
///
/// Place this near the root of your overlay widget tree (inside
/// `FloatyOverlayApp.run` or manually after [FloatyOverlay.setUp]):
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(
///   const FloatyScope(child: MyOverlayContent()),
/// );
/// ```
///
/// Then consume from any descendant:
///
/// ```dart
/// final scope = FloatyScope.of(context);
/// final lastMessage = scope.lastMessage;
/// final palette = scope.palette;
/// ```
///
/// The scope automatically disposes all subscriptions when unmounted.
/// {@endtemplate}
final class FloatyScope extends StatefulWidget {
  /// {@macro floaty_scope}
  const FloatyScope({required this.child, super.key});

  /// {@template floaty_scope.child}
  /// The widget subtree that can access [FloatyScopeData] via
  /// [FloatyScope.of].
  /// {@endtemplate}
  final Widget child;

  /// Returns the nearest [FloatyScopeData] above [context].
  ///
  /// Throws if no [FloatyScope] ancestor is found.
  static FloatyScopeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_FloatyScopeInherited>();
    assert(
      inherited != null,
      'FloatyScope.of() called without a FloatyScope ancestor.',
    );
    return inherited!.data;
  }

  /// Returns the nearest [FloatyScopeData] above [context], or `null`.
  static FloatyScopeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_FloatyScopeInherited>()
        ?.data;
  }

  @override
  State<FloatyScope> createState() => _FloatyScopeState();
}

/// {@template floaty_scope_data}
/// Snapshot of the latest overlay state exposed by [FloatyScope].
///
/// All fields update reactively as streams emit new values.
/// {@endtemplate}
class FloatyScopeData {
  /// {@macro floaty_scope_data}
  const FloatyScopeData({
    this.lastMessage,
    this.lastTappedId,
    this.lastClosedId,
    this.lastExpandedId,
    this.lastCollapsedId,
    this.lastDragStart,
    this.lastDragEnd,
    this.palette,
    this.messages = const [],
  });

  /// {@template floaty_scope_data.last_message}
  /// The most recent data message from the main app, or `null`.
  /// {@endtemplate}
  final Object? lastMessage;

  /// {@template floaty_scope_data.messages}
  /// All data messages received from the main app, in order.
  /// {@endtemplate}
  final List<Object?> messages;

  /// {@template floaty_scope_data.last_tapped_id}
  /// The ID of the chathead that was most recently tapped, or `null`.
  /// {@endtemplate}
  final String? lastTappedId;

  /// {@template floaty_scope_data.last_closed_id}
  /// The ID of the chathead that was most recently closed, or `null`.
  /// {@endtemplate}
  final String? lastClosedId;

  /// {@template floaty_scope_data.last_expanded_id}
  /// The ID of the chathead whose panel was most recently expanded,
  /// or `null`.
  /// {@endtemplate}
  final String? lastExpandedId;

  /// {@template floaty_scope_data.last_collapsed_id}
  /// The ID of the chathead whose panel was most recently collapsed,
  /// or `null`.
  /// {@endtemplate}
  final String? lastCollapsedId;

  /// {@template floaty_scope_data.last_drag_start}
  /// The most recent drag-start event, or `null`.
  /// {@endtemplate}
  final ChatHeadDragEvent? lastDragStart;

  /// {@template floaty_scope_data.last_drag_end}
  /// The most recent drag-end event, or `null`.
  /// {@endtemplate}
  final ChatHeadDragEvent? lastDragEnd;

  /// {@template floaty_scope_data.palette}
  /// The current overlay color palette, or `null` if none was sent.
  /// {@endtemplate}
  final OverlayColorPalette? palette;
}

final class _FloatyScopeState extends State<FloatyScope> {
  Object? _lastMessage;
  String? _lastTappedId;
  String? _lastClosedId;
  String? _lastExpandedId;
  String? _lastCollapsedId;
  ChatHeadDragEvent? _lastDragStart;
  ChatHeadDragEvent? _lastDragEnd;
  OverlayColorPalette? _palette;
  final List<Object?> _messages = [];

  final List<StreamSubscription<Object?>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _palette = FloatyOverlay.palette;

    _subscriptions
      ..add(
        FloatyOverlay.onData.listen((data) {
          setState(() {
            _lastMessage = data;
            _messages.add(data);
          });
        }),
      )
      ..add(
        FloatyOverlay.onTapped.listen((id) {
          setState(() => _lastTappedId = id);
        }),
      )
      ..add(
        FloatyOverlay.onClosed.listen((id) {
          setState(() => _lastClosedId = id);
        }),
      )
      ..add(
        FloatyOverlay.onExpanded.listen((id) {
          setState(() => _lastExpandedId = id);
        }),
      )
      ..add(
        FloatyOverlay.onCollapsed.listen((id) {
          setState(() => _lastCollapsedId = id);
        }),
      )
      ..add(
        FloatyOverlay.onDragStart.listen((event) {
          setState(() => _lastDragStart = event);
        }),
      )
      ..add(
        FloatyOverlay.onDragEnd.listen((event) {
          setState(() => _lastDragEnd = event);
        }),
      )
      ..add(
        FloatyOverlay.onPaletteChanged.listen((palette) {
          setState(() => _palette = palette);
        }),
      );
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FloatyScopeInherited(
      data: FloatyScopeData(
        lastMessage: _lastMessage,
        messages: List.unmodifiable(_messages),
        lastTappedId: _lastTappedId,
        lastClosedId: _lastClosedId,
        lastExpandedId: _lastExpandedId,
        lastCollapsedId: _lastCollapsedId,
        lastDragStart: _lastDragStart,
        lastDragEnd: _lastDragEnd,
        palette: _palette,
      ),
      child: widget.child,
    );
  }
}

class _FloatyScopeInherited extends InheritedWidget {
  const _FloatyScopeInherited({
    required this.data,
    required super.child,
  });

  final FloatyScopeData data;

  @override
  bool updateShouldNotify(_FloatyScopeInherited oldWidget) => true;
}
