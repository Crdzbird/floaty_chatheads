import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tears down all overlay state, then re-initialises it in order.
void resetOverlayScope() {
  FloatyConnectionState.dispose();
  FloatyOverlay.dispose();
  FloatyChannel.reset();
  FloatyChannel.ensureListening();
  FloatyOverlay.setUp();
}

/// Delivers [data] on the messenger channel without yielding afterwards.
Future<void> scopeDeliverMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );
}
