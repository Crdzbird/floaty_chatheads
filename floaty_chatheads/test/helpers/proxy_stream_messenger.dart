import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = 'ni.devotion.floaty_head/messenger';

/// Intercepts outgoing messenger sends and returns the list that collects
/// every decoded outgoing message.
List<Object?> installProxyStreamMessenger() {
  final sentMessages = <Object?>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(_channel, (message) async {
        if (message != null) {
          final decoded = const JSONMessageCodec().decodeMessage(message);
          sentMessages.add(decoded);
        }
        return const JSONMessageCodec().encodeMessage(null);
      });
  return sentMessages;
}

/// Resets the channel and removes the outgoing message interceptor.
void removeProxyStreamMessenger() {
  FloatyChannel.reset();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(_channel, null);
}

/// Simulates an incoming message on the platform channel.
Future<void> proxyStreamSimulateIncoming(Object? message) async {
  final encoded = const JSONMessageCodec().encodeMessage(message);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_channel, encoded, (reply) {});
}
