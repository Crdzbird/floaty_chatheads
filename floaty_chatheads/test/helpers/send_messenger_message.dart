import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Delivers [data] on the messenger channel as if it came from native.
Future<void> sendMessengerMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );
  await Future<void>.delayed(Duration.zero);
}
