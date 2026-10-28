import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyOverlay', () {
    setUp(FloatyOverlay.dispose);

    test('setUp registers handler and can be called multiple times', () {
      FloatyOverlay.setUp();
      FloatyOverlay.setUp();
    });

    test('dispose resets setup state', () {
      FloatyOverlay.setUp();
      FloatyOverlay.dispose();
      FloatyOverlay.setUp();
    });

    test('onData stream is broadcast', () {
      final stream = FloatyOverlay.onData
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onTapped stream is broadcast', () {
      final stream = FloatyOverlay.onTapped
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onClosed stream is broadcast', () {
      final stream = FloatyOverlay.onClosed
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onExpanded stream is broadcast', () {
      final stream = FloatyOverlay.onExpanded
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onCollapsed stream is broadcast', () {
      final stream = FloatyOverlay.onCollapsed
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onDragStart stream is broadcast', () {
      final stream = FloatyOverlay.onDragStart
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('onDragEnd stream is broadcast', () {
      final stream = FloatyOverlay.onDragEnd
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
      stream.listen((_) {});
    });

    test('onPaletteChanged stream is broadcast', () {
      final stream = FloatyOverlay.onPaletteChanged
        ..listen((_) {})
        ..listen((_) {});
      expect(stream.isBroadcast, isTrue);
    });

    test('palette returns null initially', () {
      expect(FloatyOverlay.palette, isNull);
    });
  });
}
