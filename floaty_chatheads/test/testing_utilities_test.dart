import 'dart:typed_data';

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

    test('works as drop-in for FloatyChatheads', () async {
      expect(await FloatyChatheads.checkPermission(), isTrue);
      await FloatyChatheads.showChatHead(entryPoint: 'test');
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('test'));
    });
  });

  group('FakeOverlayDataSource', () {
    late FakeOverlayDataSource source;

    setUp(() {
      source = FakeOverlayDataSource();
    });

    tearDown(() {
      source.dispose();
    });

    test('emitData adds to data stream', () async {
      final values = <Object?>[];
      source.dataController.stream.listen(values.add);
      source
        ..emitData('hello')
        ..emitData(42);
      await Future<void>.delayed(Duration.zero);
      expect(values, equals(['hello', 42]));
    });

    test('emitTapped adds to tap stream', () async {
      final ids = <String>[];
      source.tapController.stream.listen(ids.add);
      source.emitTapped('default');
      await Future<void>.delayed(Duration.zero);
      expect(ids, equals(['default']));
    });

    test('emitClose adds to close stream', () async {
      final ids = <String>[];
      source.closeController.stream.listen(ids.add);
      source.emitClose('bubble1');
      await Future<void>.delayed(Duration.zero);
      expect(ids, equals(['bubble1']));
    });

    test('emitExpanded adds to expand stream', () async {
      final ids = <String>[];
      source.expandController.stream.listen(ids.add);
      source.emitExpanded('default');
      await Future<void>.delayed(Duration.zero);
      expect(ids, equals(['default']));
    });

    test('emitCollapsed adds to collapse stream', () async {
      final ids = <String>[];
      source.collapseController.stream.listen(ids.add);
      source.emitCollapsed('default');
      await Future<void>.delayed(Duration.zero);
      expect(ids, equals(['default']));
    });

    test('emitDragStart creates event', () async {
      final events = <ChatHeadDragEvent>[];
      source.dragStartController.stream.listen(events.add);
      source.emitDragStart('default', 10, 20);
      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.id, equals('default'));
      expect(events.first.x, equals(10));
      expect(events.first.y, equals(20));
    });

    test('emitDragEnd creates event', () async {
      final events = <ChatHeadDragEvent>[];
      source.dragEndController.stream.listen(events.add);
      source.emitDragEnd('default', 100, 200);
      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.x, equals(100));
    });

    test('sendData tracks sent messages', () {
      source
        ..sendData('msg1')
        ..sendData('msg2');
      expect(source.sentData, equals(['msg1', 'msg2']));
      expect(source.lastSentData, equals('msg2'));
    });
  });
}
