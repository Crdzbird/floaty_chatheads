/// Thrown by `showChatHead` when the overlay isolate does not start
/// listening within `ChatHeadConfig.readyTimeout`. The overlay is closed
/// before this is thrown.
///
/// Usual causes: [entryPoint] does not name a top-level function, the
/// function lives outside the app's root library and no
/// [entryPointLibrary] was given, it lacks `@pragma('vm:entry-point')`
/// so release builds tree-shake it, or it never calls
/// `FloatyOverlay.setUp()` (`FloatyOverlayApp.run` does).
final class FloatyOverlayNotReadyException implements Exception {
  /// Creates the exception for the overlay that failed to start.
  const factory FloatyOverlayNotReadyException({
    required String entryPoint,
    required Duration timeout,
    String? entryPointLibrary,
  }) = FloatyOverlayNotReadyException._;

  const FloatyOverlayNotReadyException._({
    required this.entryPoint,
    required this.timeout,
    this.entryPointLibrary,
  });

  /// Name of the overlay entry point that was started.
  final String entryPoint;

  /// Library the entry point was looked up in, or `null` for the app's
  /// root library.
  final String? entryPointLibrary;

  /// How long the plugin waited for the overlay.
  final Duration timeout;

  @override
  String toString() {
    final library = entryPointLibrary ?? 'the root library';
    return 'FloatyOverlayNotReadyException: overlay entry point '
        "'$entryPoint' in $library did not start within "
        '${timeout.inMilliseconds} ms. Check that it is a top-level '
        "function annotated with @pragma('vm:entry-point') that calls "
        'FloatyOverlay.setUp() or FloatyOverlayApp.run().';
  }
}
