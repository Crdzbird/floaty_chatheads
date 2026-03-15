import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:floaty_chatheads/src/floaty_scope.dart';
import 'package:flutter/material.dart';

/// {@template floaty_overlay_app}
/// Convenience wrapper that eliminates overlay entry-point boilerplate.
///
/// Instead of writing:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() {
///   WidgetsFlutterBinding.ensureInitialized();
///   FloatyOverlay.setUp();
///   runApp(const MaterialApp(
///     debugShowCheckedModeBanner: false,
///     home: MyOverlayWidget(),
///   ));
/// }
/// ```
///
/// Write:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(const MyOverlayWidget());
/// ```
///
/// Optionally pass a [ThemeData] to style the overlay's [MaterialApp],
/// or set `debugBanner` to show/hide the debug banner.
/// {@endtemplate}
final class FloatyOverlayApp {
  FloatyOverlayApp._(); // coverage:ignore-line

  /// {@template floaty_overlay_app.run}
  /// Initializes the overlay engine, sets up the Pigeon message handler,
  /// and runs a [MaterialApp] that wraps [child].
  ///
  /// This single call replaces:
  /// - `WidgetsFlutterBinding.ensureInitialized()`
  /// - `FloatyOverlay.setUp()`
  /// - `runApp(MaterialApp(home: child))`
  ///
  /// [theme] is forwarded to `MaterialApp.theme`.
  ///
  /// [debugBanner] controls `MaterialApp.debugShowCheckedModeBanner`
  /// (defaults to `false`).
  ///
  /// [navigatorObservers] is forwarded to `MaterialApp.navigatorObservers`.
  /// {@endtemplate}
  // coverage:ignore-start
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
  // coverage:ignore-end

  /// {@template floaty_overlay_app.run_scoped}
  /// Like [run], but wraps [child] in a [FloatyScope] so that
  /// `FloatyScope.of(context)` is available throughout the overlay tree.
  ///
  /// ```dart
  /// @pragma('vm:entry-point')
  /// void overlayMain() => FloatyOverlayApp.runScoped(const MyOverlay());
  /// ```
  /// {@endtemplate}
  // coverage:ignore-start
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
  // coverage:ignore-end
}
