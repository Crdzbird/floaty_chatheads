import 'package:floaty_chatheads_android/floaty_chatheads_android.dart';
import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheadsAndroid', () {
    test('can be registered', () {
      FloatyChatheadsAndroid.registerWith();
      expect(
        FloatyChatheadsPlatform.instance,
        isA<FloatyChatheadsAndroid>(),
      );
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

      await FloatyChatheadsAndroid().showChatHead(
        const ChatHeadConfig(panelAnchor: PanelAnchor.above),
      );
      expect(received?.panelAnchor, pigeon.PanelAnchorMessage.above);

      await FloatyChatheadsAndroid().showChatHead(const ChatHeadConfig());
      expect(received?.panelAnchor, pigeon.PanelAnchorMessage.below);
      expect(received?.entryPointLibrary, isNull);

      await FloatyChatheadsAndroid().showChatHead(
        const ChatHeadConfig(entryPointLibrary: 'package:app/overlay.dart'),
      );
      expect(received?.entryPointLibrary, 'package:app/overlay.dart');
    });
  });
}
