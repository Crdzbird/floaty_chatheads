import 'package:floaty_chatheads/testing.dart';

/// A [FakeFloatyPlatform] whose [closeChatHead] always throws.
final class ThrowingClosePlatform extends FakeFloatyPlatform {
  /// Creates a platform that fails on close.
  factory ThrowingClosePlatform() = ThrowingClosePlatform._;

  ThrowingClosePlatform._();

  @override
  Future<void> closeChatHead() async {
    throw Exception('close failed');
  }
}
