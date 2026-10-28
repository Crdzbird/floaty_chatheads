import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Converts a platform-interface [IconSource] to its Pigeon message.
extension IconSourceMapper on IconSource {
  /// Returns the [pigeon.IconSourceMessage] that mirrors this source.
  pigeon.IconSourceMessage toPigeonIconSource() {
    return switch (this) {
      AssetIconSource(:final path) => pigeon.IconSourceMessage(
        type: pigeon.IconSourceTypeMessage.asset,
        path: path,
      ),
      NetworkIconSource(:final url) => pigeon.IconSourceMessage(
        type: pigeon.IconSourceTypeMessage.network,
        path: url,
      ),
      BytesIconSource(:final data) => pigeon.IconSourceMessage(
        type: pigeon.IconSourceTypeMessage.bytes,
        bytes: data,
      ),
    };
  }
}
