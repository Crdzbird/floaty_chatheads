import 'package:floaty_chatheads/testing.dart';

/// A [FakeFloatyPlatform] whose [checkPermission] always throws.
final class ThrowingShowPlatform extends FakeFloatyPlatform {
  /// Creates a platform that fails before show.
  factory ThrowingShowPlatform() = ThrowingShowPlatform._;

  ThrowingShowPlatform._();

  @override
  Future<bool> checkPermission() async {
    throw Exception('show failed');
  }
}
