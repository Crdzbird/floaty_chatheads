part of '../floaty_overlay_scope.dart';

final class _FloatyOverlayScopeInherited<S> extends InheritedWidget {
  const _FloatyOverlayScopeInherited({required this.kit, required super.child});

  final FloatyOverlayKit<S> kit;

  @override
  bool updateShouldNotify(_FloatyOverlayScopeInherited<S> oldWidget) =>
      !identical(kit, oldWidget.kit);
}
