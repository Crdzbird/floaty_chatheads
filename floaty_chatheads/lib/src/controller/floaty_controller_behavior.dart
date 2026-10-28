part of '../floaty_controller.dart';

/// Show, close and messaging behavior of [FloatyController].
base mixin _FloatyControllerBehavior on _FloatyControllerOptions {
  bool _isActive = false;
  StreamSubscription<Object?>? _dataSub;

  /// Whether the chathead is currently visible.
  bool get isActive => _isActive;

  /// Shows the chathead, handling the permission. Returns `false` when
  /// permission was denied or showing failed.
  Future<bool> show() async {
    try {
      final shown = await Floaty.show(
        entryPoint: entryPoint,
        entryPointLibrary: entryPointLibrary,
        contentWidth: contentWidth,
        contentHeight: contentHeight,
        size: sizePreset,
        theme: theme,
        flag: flag,
        enableDrag: enableDrag,
        entranceAnimation: entranceAnimation,
        panelAnchor: panelAnchor,
        autoLaunchOnBackground: autoLaunchOnBackground,
        persistOnAppClose: persistOnAppClose,
        debugMode: debugMode,
        assets: assets,
        notification: notification,
        snap: snap,
      );
      _isActive = shown;
      final listener = onData;
      if (shown && listener != null) {
        _dataSub ??= FloatyChatheads.onData.listen(listener);
      }
      notifyListeners();
      return shown;
    } on Object catch (e, st) {
      onError?.call(e, st);
      return false;
    }
  }

  /// Closes the chathead.
  Future<void> close() async {
    try {
      await FloatyChatheads.closeChatHead();
      _isActive = false;
      notifyListeners();
    } on Object catch (e, st) {
      onError?.call(e, st);
    }
  }

  /// Toggles the chathead: shows if hidden, closes if visible.
  Future<bool> toggle() async {
    if (!_isActive) return await show();
    await close();
    return false;
  }

  /// Sends data to the overlay isolate.
  Future<void> sendData(Object? data) => FloatyChatheads.shareData(data);

  @override
  void dispose() {
    unawaited(_dataSub?.cancel());
    _dataSub = null;
    FloatyChatheads.dispose();
    super.dispose();
  }
}
