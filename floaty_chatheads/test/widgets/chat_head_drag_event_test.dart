import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHeadDragEvent', () {
    test('toString includes all fields', () {
      const event = ChatHeadDragEvent(id: 'default', x: 10, y: 20);
      expect(
        event.toString(),
        equals('ChatHeadDragEvent(id: default, x: 10.0, y: 20.0)'),
      );
    });

    test('fields are accessible', () {
      const event = ChatHeadDragEvent(id: 'bubble1', x: 5.5, y: 7.3);
      expect(event.id, equals('bubble1'));
      expect(event.x, equals(5.5));
      expect(event.y, equals(7.3));
    });
  });
}
