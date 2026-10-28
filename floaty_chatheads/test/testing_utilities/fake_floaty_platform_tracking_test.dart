import 'dart:typed_data';

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

    test('addChatHead tracks config', () async {
      const config = AddChatHeadConfig(id: 'bubble1');
      await fake.addChatHead(config);
      expect(fake.lastAddConfig?.id, equals('bubble1'));
    });

    test('removeChatHead tracks ID', () async {
      await fake.removeChatHead('bubble2');
      expect(fake.lastRemovedId, equals('bubble2'));
    });

    test('updateBadge tracks count', () async {
      await fake.updateBadge(7);
      expect(fake.lastBadgeCount, equals(7));
    });

    test('reset clears all tracking state', () async {
      await fake.showChatHead(const ChatHeadConfig());
      await fake.checkPermission();
      await fake.updateBadge(3);
      fake.reset();

      expect(fake.checkPermissionCalled, isFalse);
      expect(fake.showChatHeadCalled, isFalse);
      expect(fake.closeChatHeadCalled, isFalse);
      expect(fake.lastConfig, isNull);
      expect(fake.lastBadgeCount, isNull);
    });

    test('expandChatHead completes without error', () async {
      await fake.expandChatHead();
    });

    test('collapseChatHead completes without error', () async {
      await fake.collapseChatHead();
    });

    test('updateChatHeadIcon tracks id and bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      await fake.updateChatHeadIcon('bubble1', bytes, 1, 1);
      expect(fake.lastIconId, equals('bubble1'));
      expect(fake.lastIconBytes, equals(bytes));
    });
  });
}
