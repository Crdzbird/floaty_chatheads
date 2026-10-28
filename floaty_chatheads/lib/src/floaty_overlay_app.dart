import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:floaty_chatheads/src/floaty_scope.dart';
import 'package:flutter/material.dart';

/// Convenience wrapper that removes overlay entry-point boilerplate:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(const MyOverlayWidget());
/// ```
///
/// This replaces `WidgetsFlutterBinding.ensureInitialized()`,
/// `FloatyOverlay.setUp()` and `runApp(MaterialApp(home: child))`.
final class FloatyOverlayApp {
  FloatyOverlayApp._();

  /// {@template floaty_overlay_app.run}
  /// Initializes the overlay engine, sets up the message handlers, and
  /// runs a [MaterialApp] whose home is [child].
  ///
  /// [theme] and [navigatorObservers] are forwarded to the [MaterialApp];
  /// [debugBanner] controls `debugShowCheckedModeBanner` (defaults to
  /// `false`).
  /// {@endtemplate}
  static void run(
    Widget child, {
    ThemeData? theme,
    bool debugBanner = false,
    List<NavigatorObserver> navigatorObservers = const [],
  }) {
    WidgetsFlutterBinding.ensureInitialized();
    FloatyOverlay.setUp();
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: debugBanner,
        theme: theme,
        navigatorObservers: navigatorObservers,
        home: child,
      ),
    );
  }

  /// {@template floaty_overlay_app.run_scoped}
  /// Like [run], but wraps [child] in a [FloatyScope] so that
  /// `FloatyScope.of(context)` is available throughout the overlay tree.
  /// {@endtemplate}
  static void runScoped(
    Widget child, {
    ThemeData? theme,
    bool debugBanner = false,
    List<NavigatorObserver> navigatorObservers = const [],
  }) {
    run(
      FloatyScope(child: child),
      theme: theme,
      debugBanner: debugBanner,
      navigatorObservers: navigatorObservers,
    );
  }
}
