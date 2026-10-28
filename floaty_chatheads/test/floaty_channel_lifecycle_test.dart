import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _codec = JSONMessageCodec();

Future<Object?> _deliver(Object? data) async {
  Object? reply;
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        FloatyChannels.messenger,
        _codec.encodeMessage(data),
        (bytes) => reply = _codec.decodeMessage(bytes),
      );
  await Future<void>.delayed(Duration.zero);
  return reply;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.reset);

  test('answers the ready ping once listening', () async {
    FloatyChannel.ensureListening();
    final reply = await _deliver(<String, Object?>{
      FloatyChannels.envelope: FloatyChannels.ping,
      FloatyChannels.ping: <String, Object?>{},
    });
    expect(reply, FloatyChannels.pong);
  });

  test('keeps raw messages that arrive before the first listener', () async {
    FloatyChannel.ensureListening();
    await _deliver('early');
    final received = <Object?>[];
    FloatyChannel.rawMessages.listen(received.add);
    await Future<void>.delayed(Duration.zero);
    expect(received, ['early']);
  });

  test('FloatyChatheads.dispose keeps other components connected', () async {
    final received = <Map<String, dynamic>>[];
    FloatyChannel.registerHandler('_floaty_state', received.add);
    FloatyChannel.ensureListening();
    FloatyChatheads.dispose();
    await _deliver(<String, Object?>{
      FloatyChannels.envelope: '_floaty_state',
      '_floaty_state': <String, Object?>{'full': true},
    });
    expect(received, hasLength(1));
  });

  test('FloatyOverlay.dispose keeps other components connected', () async {
    final received = <Map<String, dynamic>>[];
    FloatyChannel.registerHandler('_floaty_action', received.add);
    FloatyChannel.ensureListening();
    FloatyOverlay.dispose();
    await _deliver(<String, Object?>{
      FloatyChannels.envelope: '_floaty_action',
      '_floaty_action': <String, Object?>{'type': 'ping'},
    });
    expect(received, hasLength(1));
  });
}
