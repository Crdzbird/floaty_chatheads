import 'package:floaty_chatheads_android/floaty_chatheads_android.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheadsAndroid', () {
    test('can be registered', () {
      FloatyChatheadsAndroid.registerWith();
      expect(
        FloatyChatheadsPlatform.instance,
        isA<FloatyChatheadsAndroid>(),
      );
    });
  });
}
