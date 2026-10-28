import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Delivers [data] on the messenger channel as if it came from native,
/// then yields one microtask turn.
Future<void> channelSimulateMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'ni.devotion.floaty_head/messenger',
        encoded,
        (data) {},
      );
  await Future<void>.delayed(Duration.zero);
}

/// Wraps a prefixed payload in the system envelope used by the channel.
Map<String, Object?> channelSystemEnvelope(
  String prefix,
  Map<String, dynamic> payload,
) => <String, Object?>{'__floaty__': prefix, prefix: payload};
