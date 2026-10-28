import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mocktail platform used by the AnimatedWidgetIcon tests.
final class AnimatedIconMockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FloatyChatheadsPlatform {
  /// Creates a fresh mock platform.
  factory AnimatedIconMockPlatform() = AnimatedIconMockPlatform._;

  AnimatedIconMockPlatform._();
}
