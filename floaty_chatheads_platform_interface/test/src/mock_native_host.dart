import 'package:floaty_chatheads_platform_interface/src/method_channel_floaty_chatheads.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers calls on the channel of [platform] like a native host would and
/// records every call in [log].
void mockNativeHost(
  MethodChannelFloatyChatheads platform,
  List<MethodCall> log,
) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(platform.methodChannel, (call) async {
        log.add(call);
        return switch (call.method) {
          'checkPermission' || 'requestPermission' => true,
          'isActive' => false,
          'getOverlayPosition' => <String, double>{'x': 5.0, 'y': 10.0},
          _ => null,
        };
      });
}
