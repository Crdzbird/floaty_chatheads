import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHeadTheme', () {
    test('equality uses map content, not identity', () {
      const a = ChatHeadTheme(
        badgeColor: 0xFFFF0000,
        overlayPalette: {'primary': 0xFF000000, 'surface': 0xFFFFFFFF},
      );
      const b = ChatHeadTheme(
        badgeColor: 0xFFFF0000,
        overlayPalette: {'primary': 0xFF000000, 'surface': 0xFFFFFFFF},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode is order-independent for overlayPalette', () {
      final palette1 = <String, int>{}
        ..['primary'] = 0xFF000000
        ..['surface'] = 0xFFFFFFFF
        ..['error'] = 0xFFFF0000;
      final palette2 = <String, int>{}
        ..['error'] = 0xFFFF0000
        ..['surface'] = 0xFFFFFFFF
        ..['primary'] = 0xFF000000;

      final a = ChatHeadTheme(overlayPalette: palette1);
      final b = ChatHeadTheme(overlayPalette: palette2);

      expect(a, equals(b));
      expect(
        a.hashCode,
        equals(b.hashCode),
        reason: 'hashCode must be order-independent for equal maps',
      );
    });

    test('null overlayPalette produces consistent hash', () {
      const a = ChatHeadTheme(badgeColor: 0xFF00FF00);
      const b = ChatHeadTheme(badgeColor: 0xFF00FF00);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different overlayPalette values produce different hashes', () {
      const a = ChatHeadTheme(overlayPalette: {'primary': 0xFF000000});
      const b = ChatHeadTheme(overlayPalette: {'primary': 0xFFFFFFFF});
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
