import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A mocktail mock of [FloatyChatheadsPlatform].
final class MockFloatyChatheadsPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FloatyChatheadsPlatform {
  /// Creates a mock platform.
  factory MockFloatyChatheadsPlatform() = MockFloatyChatheadsPlatform._;

  MockFloatyChatheadsPlatform._();
}
