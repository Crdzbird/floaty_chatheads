import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_android/src/icon_source_mapper.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Converts a platform-interface [AddChatHeadConfig] to its Pigeon message.
extension AddChatHeadConfigMapper on AddChatHeadConfig {
  /// Returns the [pigeon.AddChatHeadConfig] sent to the Kotlin host API.
  ///
  /// The icon is taken from `iconSource` when set, otherwise from
  /// `iconAsset` wrapped as an asset source.
  pigeon.AddChatHeadConfig toPigeonAddConfig() {
    return pigeon.AddChatHeadConfig(
      id: id,
      iconAsset: iconAsset,
      iconSource: _iconMessage(),
    );
  }

  pigeon.IconSourceMessage? _iconMessage() {
    final source = iconSource;
    if (source != null) return source.toPigeonIconSource();
    final asset = iconAsset;
    if (asset == null) return null;
    return IconSource.asset(asset).toPigeonIconSource();
  }
}
