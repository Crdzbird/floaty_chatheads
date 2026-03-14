import 'package:floaty_chatheads_ios/floaty_chatheads_ios.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheadsIOS', () {
    test('can be registered', () {
      FloatyChatheadsIOS.registerWith();
      expect(
        FloatyChatheadsPlatform.instance,
        isA<FloatyChatheadsIOS>(),
      );
    });
  });
}
