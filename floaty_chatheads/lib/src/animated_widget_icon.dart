import 'dart:async';
import 'dart:typed_data';

import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Signature for a builder that receives the current normalised animation
/// value (0.0 – 1.0) and returns a widget to render as the chathead icon.
typedef AnimatedIconBuilder = Widget Function(double animationValue);

/// Drives an animated chathead icon by periodically rendering a widget
/// to raw RGBA bytes and pushing them to the native layer.
///
/// The rendering uses an **offscreen pipeline** (separate `RenderView`
/// and `PipelineOwner`) so the main widget tree is never blocked.
/// GPU rasterisation and byte extraction are async (raster thread).
/// On Android the native bitmap creation runs on `Dispatchers.Default`.
///
/// ## Usage
///
/// ```dart
/// final animated = AnimatedWidgetIcon(
///   id: 'default',
///   builder: (value) => Transform.rotate(
///     angle: value * 2 * pi,
///     child: const Icon(Icons.sync, size: 60),
///   ),
///   fps: 24,
///   size: 80,
///   duration: const Duration(seconds: 1),
/// );
///
/// // Capture the first frame for showChatHead().
/// await animated.init();
///
/// await FloatyChatheads.showChatHead(
///   entryPoint: 'overlayMain',
///   assets: ChatHeadAssets(
///     icon: animated.initialFrame,
///     closeIcon: IconSource.asset('assets/close.png'),
///     closeBackground: IconSource.asset('assets/closeBg.png'),
///   ),
/// );
///
/// // Start the render loop.
/// animated.start();
///
/// // Later — clean up.
/// animated.dispose();
/// ```
class AnimatedWidgetIcon {
  /// Creates an animated widget icon controller.
  AnimatedWidgetIcon({
    required this.id,
    required this.builder,
    this.fps = 24,
    this.size = 80,
    this.pixelRatio = 3.0,
    this.duration = const Duration(seconds: 1),
  });

  /// Chathead ID that this animation targets.
  final String id;

  /// Frames per second for the render loop. Higher values are smoother
  /// but increase method-channel throughput.
  final int fps;

  /// Logical size (width = height) of the rendered icon.
  final double size;

  /// Device-pixel ratio for rasterisation.
  final double pixelRatio;

  /// Total animation cycle duration. The normalised value passed to
  /// the builder goes from 0.0 to 1.0 over this period, then repeats.
  final Duration duration;

  /// The current builder function. Assign a new value to change the
  /// animation — takes effect on the next frame.
  AnimatedIconBuilder builder;

  IconSource? _initialFrame;

  /// The first rendered frame. Available after [init] completes.
  ///
  /// Pass this to [ChatHeadAssets.icon] when calling `showChatHead`.
  IconSource get initialFrame {
    assert(_initialFrame != null, 'Call init() before accessing initialFrame.');
    return _initialFrame!;
  }

  Timer? _timer;
  bool _rendering = false;
  final Stopwatch _stopwatch = Stopwatch();

  static FloatyChatheadsPlatform get _platform =>
      FloatyChatheadsPlatform.instance;

  /// Renders the first frame and stores it as [initialFrame].
  ///
  /// Call this **before** `showChatHead` so you can pass [initialFrame]
  /// as the chathead icon source.
  Future<void> init() async {
    final widget = builder(0);
    _initialFrame = await widgetToIconSource(
      widget,
      size: size,
      pixelRatio: pixelRatio,
    );
  }

  /// Starts the periodic render loop at [fps].
  ///
  /// Each tick:
  /// 1. Computes the normalised animation value from elapsed time.
  /// 2. Builds the widget via the builder.
  /// 3. Renders to raw RGBA bytes (offscreen pipeline + raster thread).
  /// 4. Sends bytes to native via `updateChatHeadIcon`.
  void start() {
    if (_timer != null) return;
    _stopwatch
      ..reset()
      ..start();

    final interval = Duration(milliseconds: 1000 ~/ fps);
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  /// Stops the render loop without disposing resources.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }


  /// Stops the render loop and releases resources.
  void dispose() {
    stop();
  }

  Future<void> _tick() async {
    // Skip if the previous frame hasn't finished sending yet.
    if (_rendering) return;
    _rendering = true;

    try {
      final elapsed = _stopwatch.elapsedMilliseconds;
      final durationMs = duration.inMilliseconds;
      final value = (elapsed % durationMs) / durationMs;
      final widget = builder(value);

      final (:bytes, :width, :height) = await renderWidgetToRgbaByteData(
        widget,
        size: size,
        pixelRatio: pixelRatio,
      );

      await _platform.updateChatHeadIcon(
        id,
        Uint8List.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes),
        width,
        height,
      );
    } finally {
      _rendering = false;
    }
  }
}
