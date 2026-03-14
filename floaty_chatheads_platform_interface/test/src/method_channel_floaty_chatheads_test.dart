import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:floaty_chatheads_platform_interface/src/method_channel_floaty_chatheads.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelFloatyChatheads', () {
    late MethodChannelFloatyChatheads methodChannel;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannel = MethodChannelFloatyChatheads();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'checkPermission':
              return true;
            case 'requestPermission':
              return true;
            case 'isActive':
              return false;
            case 'getOverlayPosition':
              return <String, double>{'x': 5.0, 'y': 10.0};
            default:
              return null;
          }
        },
      );
    });

    tearDown(log.clear);

    test('checkPermission', () async {
      final result = await methodChannel.checkPermission();
      expect(
        log,
        <Matcher>[isMethodCall('checkPermission', arguments: null)],
      );
      expect(result, isTrue);
    });

    test('requestPermission', () async {
      final result = await methodChannel.requestPermission();
      expect(
        log,
        <Matcher>[isMethodCall('requestPermission', arguments: null)],
      );
      expect(result, isTrue);
    });

    test('isActive', () async {
      final result = await methodChannel.isActive();
      expect(
        log,
        <Matcher>[isMethodCall('isActive', arguments: null)],
      );
      expect(result, isFalse);
    });

    test('closeChatHead', () async {
      await methodChannel.closeChatHead();
      expect(
        log,
        <Matcher>[isMethodCall('closeChatHead', arguments: null)],
      );
    });

    test('closeOverlay', () async {
      await methodChannel.closeOverlay();
      expect(
        log,
        <Matcher>[isMethodCall('closeOverlay', arguments: null)],
      );
    });

    test('getOverlayPosition', () async {
      final pos = await methodChannel.getOverlayPosition();
      expect(pos.x, equals(5.0));
      expect(pos.y, equals(10.0));
    });

    test('showChatHead', () async {
      await methodChannel.showChatHead(const ChatHeadConfig());
      expect(log.length, equals(1));
      expect(log.first.method, equals('showChatHead'));
    });

    test('addChatHead', () async {
      await methodChannel.addChatHead(
        const AddChatHeadConfig(id: 'test'),
      );
      expect(log.length, equals(1));
      expect(log.first.method, equals('addChatHead'));
    });

    test('removeChatHead', () async {
      await methodChannel.removeChatHead('test');
      expect(log.length, equals(1));
      expect(log.first.method, equals('removeChatHead'));
    });
  });
}
