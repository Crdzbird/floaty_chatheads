import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FakeOverlayDataSource', () {
    late FakeOverlayDataSource source;

    setUp(() {
      source = FakeOverlayDataSource();
    });

    tearDown(() async {
      await source.dispose();
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
