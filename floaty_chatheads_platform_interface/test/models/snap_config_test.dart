import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SnapConfig', () {
    test('constructor stores all fields', () {
      const config = SnapConfig(
        edge: SnapEdge.left,
        margin: 5,
        persistPosition: true,
      );
      expect(config.edge, SnapEdge.left);
      expect(config.margin, 5);
      expect(config.persistPosition, isTrue);
    });

    test('defaults to both / -10 / false', () {
      const config = SnapConfig();
      expect(config.edge, SnapEdge.both);
      expect(config.margin, -10);
      expect(config.persistPosition, isFalse);
    });
  });
}
