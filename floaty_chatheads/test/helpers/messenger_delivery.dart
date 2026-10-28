import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Delivers [data] on the messenger channel and waits one event-loop turn.
Future<void> deliverMessengerMessage(Object? data) async {
  await deliverMessengerMessageNow(data);
  await Future<void>.delayed(Duration.zero);
}

/// Delivers [data] on the messenger channel without waiting afterwards.
Future<void> deliverMessengerMessageNow(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );
}
