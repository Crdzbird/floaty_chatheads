import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('entryPointLibrary', () {
    test('defaults to null (root library)', () {
      expect(const ChatHeadConfig().entryPointLibrary, isNull);
    });

    test('participates in equality', () {
      const a = ChatHeadConfig(entryPointLibrary: 'package:app/a.dart');
      const b = ChatHeadConfig(entryPointLibrary: 'package:app/b.dart');
      expect(a, isNot(equals(b)));
      expect(
        a,
        equals(const ChatHeadConfig(entryPointLibrary: 'package:app/a.dart')),
      );
    });
  });

  group('PanelAnchor', () {
    test('ChatHeadConfig defaults to below', () {
      const config = ChatHeadConfig();
      expect(config.panelAnchor, PanelAnchor.below);
    });

    test('is stored on ChatHeadConfig', () {
      const config = ChatHeadConfig(panelAnchor: PanelAnchor.auto);
      expect(config.panelAnchor, PanelAnchor.auto);
    });

    test('enum order is a wire contract (index-serialized)', () {
      expect(PanelAnchor.values, const [
        PanelAnchor.below,
        PanelAnchor.above,
        PanelAnchor.auto,
      ]);
    });

    test('participates in ChatHeadConfig equality and hashCode', () {
      const below = ChatHeadConfig();
      const above = ChatHeadConfig(panelAnchor: PanelAnchor.above);
      expect(below, equals(const ChatHeadConfig()));
      expect(below, isNot(equals(above)));
      expect(below.hashCode, isNot(equals(above.hashCode)));
    });
  });
}
