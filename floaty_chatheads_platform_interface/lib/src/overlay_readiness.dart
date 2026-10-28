import 'dart:async';

import 'package:floaty_chatheads_platform_interface/src/floaty_channels.dart';
import 'package:floaty_chatheads_platform_interface/src/models/chat_head_config.dart';
import 'package:floaty_chatheads_platform_interface/src/overlay_not_ready_exception.dart';
import 'package:flutter/services.dart';

/// Confirms the overlay isolate is listening before `showChatHead`
/// returns, so data sent right after showing is not lost and a broken
/// entry point fails loudly instead of leaving a blank overlay.
final class OverlayReadiness {
  const OverlayReadiness._();

  static const BasicMessageChannel<Object?> _channel =
      BasicMessageChannel<Object?>(
    FloatyChannels.messenger,
    JSONMessageCodec(),
  );

  static const Map<String, Object?> _ping = <String, Object?>{
    FloatyChannels.envelope: FloatyChannels.ping,
    FloatyChannels.ping: <String, Object?>{},
  };

  static const Duration _pingTimeout = Duration(milliseconds: 300);
  static const Duration _retryDelay = Duration(milliseconds: 100);

  /// Waits up to `config.readyTimeout` for the overlay to answer. On
  /// timeout runs [closeOverlay] and throws
  /// [FloatyOverlayNotReadyException]. `Duration.zero` skips the check.
  static Future<void> ensureReady(
    ChatHeadConfig config, {
    required Future<void> Function() closeOverlay,
  }) async {
    if (config.readyTimeout == Duration.zero) return;
    if (await waitUntilReady(config.readyTimeout)) return;
    await closeOverlay();
    throw FloatyOverlayNotReadyException(
      entryPoint: config.entryPoint,
      entryPointLibrary: config.entryPointLibrary,
      timeout: config.readyTimeout,
    );
  }

  /// Pings the overlay until it replies or [timeout] elapses. Returns
  /// whether it replied.
  static Future<bool> waitUntilReady(Duration timeout) async {
    final watch = Stopwatch()..start();
    while (watch.elapsed < timeout) {
      if (await _pingOnce()) return true;
      await Future<void>.delayed(_retryDelay);
    }
    return false;
  }

  static Future<bool> _pingOnce() async {
    final reply = await _channel
        .send(_ping)
        .timeout(_pingTimeout, onTimeout: () => null);
    return reply == FloatyChannels.pong;
  }
}
