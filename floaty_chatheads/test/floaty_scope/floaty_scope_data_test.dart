import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyConnectionState.dispose();
    FloatyOverlay.dispose();
    FloatyOverlay.setUp();
    FloatyConnectionState.setUp();
  });

  group('FloatyScopeData', () {
    test('default constructor provides empty state', () {
      const data = FloatyScopeData();
      expect(data.lastMessage, isNull);
      expect(data.messages, isEmpty);
      expect(data.lastTappedId, isNull);
      expect(data.palette, isNull);
    });

    test('constructor accepts all fields', () {
      const event = ChatHeadDragEvent(id: 'default', x: 10, y: 20);
      const data = FloatyScopeData(
        lastMessage: 'hello',
        messages: ['hello', 'world'],
        lastTappedId: 'default',
        lastClosedId: 'bubble1',
        lastExpandedId: 'default',
        lastCollapsedId: 'bubble1',
        lastDragStart: event,
        lastDragEnd: event,
      );
      expect(data.lastMessage, equals('hello'));
      expect(data.messages.length, equals(2));
      expect(data.lastTappedId, equals('default'));
      expect(data.lastDragStart?.x, equals(10));
    });
  });
}
