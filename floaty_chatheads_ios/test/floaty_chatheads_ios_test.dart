import 'package:floaty_chatheads_ios/floaty_chatheads_ios.dart';
import 'package:floaty_chatheads_ios/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheadsIOS', () {
    test('can be registered', () {
      FloatyChatheadsIOS.registerWith();
      expect(FloatyChatheadsPlatform.instance, isA<FloatyChatheadsIOS>());
    });

    test('showChatHead maps panelAnchor into the Pigeon message', () async {
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.floaty_chatheads.FloatyHostApi.showChatHead',
        pigeon.FloatyHostApi.pigeonChannelCodec,
      );
      pigeon.ChatHeadConfig? received;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(channel, (message) async {
            final args = message! as List<Object?>;
            received = args[0]! as pigeon.ChatHeadConfig;
            return <Object?>[];
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(channel, null),
      );
      const overlay = BasicMessageChannel<Object?>(
        FloatyChannels.messenger,
        JSONMessageCodec(),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
            overlay,
            (_) async => FloatyChannels.pong,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(overlay, null),
      );

      await FloatyChatheadsIOS().showChatHead(
        const ChatHeadConfig(panelAnchor: PanelAnchor.auto),
      );
      expect(received?.panelAnchor, pigeon.PanelAnchorMessage.auto);

      await FloatyChatheadsIOS().showChatHead(const ChatHeadConfig());
      expect(received?.panelAnchor, pigeon.PanelAnchorMessage.below);
      expect(received?.entryPointLibrary, isNull);

      await FloatyChatheadsIOS().showChatHead(
        const ChatHeadConfig(entryPointLibrary: 'package:app/overlay.dart'),
      );
      expect(received?.entryPointLibrary, 'package:app/overlay.dart');
    });
  });
}
