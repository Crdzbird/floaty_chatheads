import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:floaty_chatheads_platform_interface/src/method_channel_floaty_chatheads.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_native_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelFloatyChatheads', () {
    late MethodChannelFloatyChatheads methodChannel;
    final log = <MethodCall>[];

    setUp(() {
      methodChannel = MethodChannelFloatyChatheads();
      mockNativeHost(methodChannel, log);
    });

    tearDown(log.clear);

    test('showChatHead', () async {
      await methodChannel.showChatHead(const ChatHeadConfig());
      expect(log.length, equals(1));
      expect(log.first.method, equals('showChatHead'));
    });

    test('showChatHead serializes panelAnchor.below by default', () async {
      await methodChannel.showChatHead(const ChatHeadConfig());
      final args = log.first.arguments as Map<Object?, Object?>;
      expect(args['panelAnchor'], equals(PanelAnchor.below.index));
    });

    test('showChatHead serializes entryPointLibrary', () async {
      await methodChannel.showChatHead(
        const ChatHeadConfig(entryPointLibrary: 'package:app/overlay.dart'),
      );
      final args = log.first.arguments as Map<Object?, Object?>;
      expect(args['entryPointLibrary'], equals('package:app/overlay.dart'));
    });

    test('showChatHead serializes non-default panelAnchor by index', () async {
      await methodChannel.showChatHead(
        const ChatHeadConfig(panelAnchor: PanelAnchor.above),
      );
      final args = log.first.arguments as Map<Object?, Object?>;
      expect(args['panelAnchor'], equals(PanelAnchor.above.index));
    });
  });
}
