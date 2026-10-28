import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Floaty', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('show defaults to the card preset and the below anchor', () async {
      await Floaty.show();
      expect(fake.lastConfig?.sizePreset, equals(ContentSizePreset.card));
      expect(fake.lastConfig?.panelAnchor, equals(PanelAnchor.below));
    });

    test('show passes a named size preset', () async {
      await Floaty.show(size: ContentSizePreset.halfScreen);
      expect(fake.lastConfig?.sizePreset, equals(ContentSizePreset.halfScreen));
    });

    test('explicit dimensions replace the size preset', () async {
      await Floaty.show(contentWidth: 320, contentHeight: 480);
      expect(fake.lastConfig?.sizePreset, isNull);
      expect(fake.lastConfig?.contentWidth, equals(320));
      expect(fake.lastConfig?.contentHeight, equals(480));
    });

    test('title becomes the notification title', () async {
      await Floaty.show(title: 'My App');
      expect(fake.lastConfig?.notification?.title, equals('My App'));
    });

    test('an explicit notification wins over title', () async {
      await Floaty.show(
        title: 'ignored',
        notification: const NotificationConfig(title: 'explicit'),
      );
      expect(fake.lastConfig?.notification?.title, equals('explicit'));
    });
  });
}
