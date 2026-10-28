import 'package:floaty_chatheads/src/generated/floaty_chatheads_overlay_api.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simulates the native side reporting a tap on the chathead [id].
Future<void> simulateOverlayChatHeadTap(String id) async {
  final encoded = FloatyOverlayFlutterApi.pigeonChannelCodec.encodeMessage(
    <Object?>[id],
  );
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'dev.flutter.pigeon.floaty_chatheads.'
        'FloatyOverlayFlutterApi.onChatHeadTapped',
        encoded,
        (data) {},
      );
}
