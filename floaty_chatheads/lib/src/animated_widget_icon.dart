import 'dart:async';

import 'package:floaty_chatheads/src/icons/animated_icon_builder.dart';
import 'package:floaty_chatheads/src/icons/icon_animation_clock.dart';
import 'package:floaty_chatheads/src/icons/icon_frame_sender.dart';
import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

export 'package:floaty_chatheads/src/icons/animated_icon_builder.dart';

/// Drives an animated chathead icon by periodically rendering a widget
/// offscreen and pushing the frames to the native layer. Call [init] and
/// pass [initialFrame] to `showChatHead`, then [start]; [dispose] when done.
final class AnimatedWidgetIcon {
  /// Creates the controller; [fps] and [duration] must be positive.
  factory AnimatedWidgetIcon({
    required String id,
    required AnimatedIconBuilder builder,
    int fps,
    double size,
    double pixelRatio,
    Duration duration,
  }) = AnimatedWidgetIcon._;

  AnimatedWidgetIcon._({
    required this.id,
    required this.builder,
    this.fps = 24,
    this.size = 80,
    this.pixelRatio = 3.0,
    this.duration = const Duration(seconds: 1),
  }) : assert(fps > 0, 'fps must be greater than zero'),
       assert(
         duration > Duration.zero,
         'duration must be greater than Duration.zero',
       );

  /// Chathead ID that this animation targets.
  final String id;

  /// Frames per second for the render loop.
  final int fps;

  /// Logical size (width = height) of the rendered icon.
  final double size;

  /// Device-pixel ratio for rasterisation.
  final double pixelRatio;

  /// One animation cycle; the builder value runs from 0.0 to 1.0 per cycle.
  final Duration duration;

  /// The current builder. Assigning a new one takes effect next frame.
  AnimatedIconBuilder builder;

  IconSource? _initialFrame;
  late final IconFrameSender _sender = IconFrameSender(
    id: id,
    size: size,
    pixelRatio: pixelRatio,
  );
  final IconAnimationClock _clock = IconAnimationClock();

  /// The first rendered frame. Available after [init] completes.
  IconSource get initialFrame {
    assert(_initialFrame != null, 'Call init() before accessing initialFrame.');
    return _initialFrame!;
  }

  /// Whether the render loop is currently active.
  bool get isRunning => _clock.isRunning;

  /// Renders the first frame and stores it as [initialFrame].
  Future<void> init() async => _initialFrame = await widgetToIconSource(
    builder(0),
    size: size,
    pixelRatio: pixelRatio,
  );

  /// Starts the periodic render loop at [fps].
  void start() {
    if (isRunning) return;
    _clock.start(fps, () => unawaited(tick()));
  }

  /// Stops the render loop; [start] can resume it.
  void stop() => _clock.stop();

  /// Stops the render loop and releases resources.
  void dispose() => stop();

  /// Renders a single frame and sends it to the platform. Called by the
  /// timer while running; exposed for testing only.
  @visibleForTesting
  Future<void> tick() => _sender.send(() => builder(_clock.progress(duration)));
}
