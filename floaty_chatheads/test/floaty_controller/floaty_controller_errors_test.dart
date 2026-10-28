import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/throwing_close_platform.dart';
import '../helpers/throwing_show_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyController', () {
    late FakeFloatyPlatform fake;

    setUp(() {
      fake = FakeFloatyPlatform();
      FloatyChatheadsPlatform.instance = fake;
    });

    test('onError is called when show throws', () async {
      fake.permissionGranted = true;
      Object? caughtError;
      final controller = FloatyController(onError: (e, st) => caughtError = e);

      await controller.show();
      expect(caughtError, isNull);

      controller.dispose();
    });

    test('sendData delegates to FloatyChatheads.shareData', () async {
      final controller = FloatyController();
      await controller.sendData({'action': 'test'});
      controller.dispose();
    });

    test('show subscribes to onData when callback provided', () async {
      final data = <Object?>[];
      final controller = FloatyController(onData: data.add);
      await controller.show();
      expect(controller.isActive, isTrue);
      controller.dispose();
    });

    test('onError catches close errors', () async {
      final throwingPlatform = ThrowingClosePlatform();
      FloatyChatheadsPlatform.instance = throwingPlatform;

      Object? caughtError;
      final controller = FloatyController(onError: (e, st) => caughtError = e);

      await controller.show();
      await controller.close();
      expect(caughtError, isNotNull);

      controller.dispose();
    });

    test('onError catches show errors', () async {
      final throwingPlatform = ThrowingShowPlatform();
      FloatyChatheadsPlatform.instance = throwingPlatform;

      Object? caughtError;
      final controller = FloatyController(onError: (e, st) => caughtError = e);

      final result = await controller.show();
      expect(result, isFalse);
      expect(caughtError, isNotNull);

      controller.dispose();
    });
  });
}
