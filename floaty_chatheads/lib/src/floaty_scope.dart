import 'dart:async';

import 'package:floaty_chatheads/src/floaty_connection_state.dart';
import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:floaty_chatheads/src/scope/floaty_scope_data.dart';
import 'package:flutter/widgets.dart';

export 'package:floaty_chatheads/src/scope/floaty_scope_data.dart';

part 'scope/floaty_scope_inherited.dart';
part 'scope/floaty_scope_state.dart';

/// Subscribes to every [FloatyOverlay] stream and exposes the latest
/// values to descendants as [FloatyScopeData].
///
/// Place it near the root of the overlay tree, for example with
/// `FloatyOverlayApp.runScoped`, then read `FloatyScope.of(context)`.
/// Subscriptions are cancelled when the scope unmounts.
final class FloatyScope extends StatefulWidget {
  /// Creates a scope around [child].
  const factory FloatyScope({required Widget child, Key? key}) = FloatyScope._;

  const FloatyScope._({required this.child, super.key});

  /// The subtree that can read [FloatyScopeData] via [FloatyScope.of].
  final Widget child;

  /// Returns the nearest [FloatyScopeData]; asserts that a [FloatyScope]
  /// ancestor exists.
  static FloatyScopeData of(BuildContext context) {
    final data = maybeOf(context);
    assert(
      data != null,
      'FloatyScope.of() called without a FloatyScope ancestor.',
    );
    return data!;
  }

  /// Returns the nearest [FloatyScopeData] above [context], or `null`.
  static FloatyScopeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FloatyScopeInherited>()?.data;

  @override
  State<FloatyScope> createState() => _FloatyScopeState();
}
