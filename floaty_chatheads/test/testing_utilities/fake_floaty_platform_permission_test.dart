import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FakeFloatyPlatform', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('checkPermission tracks call and returns configured value', () async {
      expect(fake.checkPermissionCalled, isFalse);
      final result = await fake.checkPermission();
      expect(result, isTrue);
      expect(fake.checkPermissionCalled, isTrue);
    });

    test('permissionGranted controls permission results', () async {
      fake.permissionGranted = false;
      expect(await fake.checkPermission(), isFalse);
      expect(await fake.requestPermission(), isFalse);
    });

    test('showChatHead tracks config', () async {
      const config = ChatHeadConfig(entryPoint: 'myOverlay');
      await fake.showChatHead(config);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('myOverlay'));
      expect(fake.active, isTrue);
    });

    test('closeChatHead sets active to false', () async {
      await fake.showChatHead(const ChatHeadConfig());
      expect(fake.active, isTrue);
      await fake.closeChatHead();
      expect(fake.active, isFalse);
      expect(fake.closeChatHeadCalled, isTrue);
    });

    test('isActive reflects state', () async {
      expect(await fake.isActive(), isFalse);
      await fake.showChatHead(const ChatHeadConfig());
      expect(await fake.isActive(), isTrue);
    });

    test('works as drop-in for FloatyChatheads', () async {
      expect(await FloatyChatheads.checkPermission(), isTrue);
      await FloatyChatheads.showChatHead(entryPoint: 'test');
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('test'));
    });
  });
}
