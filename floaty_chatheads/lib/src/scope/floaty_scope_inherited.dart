part of '../floaty_scope.dart';

final class _FloatyScopeInherited extends InheritedWidget {
  const _FloatyScopeInherited({required this.data, required super.child});

  final FloatyScopeData data;

  @override
  bool updateShouldNotify(_FloatyScopeInherited oldWidget) =>
      !identical(data, oldWidget.data);
}
