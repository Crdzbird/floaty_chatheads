import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationConfig', () {
    test('constructor stores all fields', () {
      const config = NotificationConfig(
        title: 'My Overlay',
        description: 'Overlay is active',
        iconAsset: 'assets/icon.png',
        visibility: NotificationVisibility.visibilityPrivate,
      );
      expect(config.title, 'My Overlay');
      expect(config.description, 'Overlay is active');
      expect(config.iconAsset, 'assets/icon.png');
      expect(config.visibility, NotificationVisibility.visibilityPrivate);
    });

    test('defaults to visibilityPublic and null description', () {
      const config = NotificationConfig();
      expect(config.title, isNull);
      expect(config.description, isNull);
      expect(config.iconAsset, isNull);
      expect(config.visibility, NotificationVisibility.visibilityPublic);
    });
  });
}
