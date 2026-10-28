import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyController', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('show launches chathead and sets isActive', () async {
      final controller = FloatyController(entryPoint: 'test');
      expect(controller.isActive, isFalse);

      await controller.show();
      expect(controller.isActive, isTrue);
      expect(fake.showChatHeadCalled, isTrue);
      expect(fake.lastConfig?.entryPoint, equals('test'));

      controller.dispose();
    });

    test('close stops chathead and clears isActive', () async {
      final controller = FloatyController();
      await controller.show();
      expect(controller.isActive, isTrue);

      await controller.close();
      expect(controller.isActive, isFalse);
      expect(fake.closeChatHeadCalled, isTrue);

      controller.dispose();
    });

    test('toggle shows when inactive', () async {
      final controller = FloatyController();
      final result = await controller.toggle();
      expect(result, isTrue);
      expect(controller.isActive, isTrue);
      controller.dispose();
    });

    test('toggle closes when active', () async {
      final controller = FloatyController();
      await controller.show();

      final result = await controller.toggle();
      expect(result, isFalse);
      expect(controller.isActive, isFalse);

      controller.dispose();
    });

    test('show returns false when permission denied', () async {
      fake.permissionGranted = false;
      final controller = FloatyController();
      final result = await controller.show();
      expect(result, isFalse);
      expect(controller.isActive, isFalse);
      controller.dispose();
    });
  });
}
