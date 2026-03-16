import 'package:floaty_chatheads_platform_interface/src/models/icon_source.dart';

/// {@template add_chat_head_config}
/// Configuration for adding a chathead bubble to an existing group.
/// {@endtemplate}
class AddChatHeadConfig {
  /// {@macro add_chat_head_config}
  const AddChatHeadConfig({
    required this.id,
    this.iconAsset,
    this.iconSource,
  });

  /// {@template add_chat_head_config.id}
  /// Unique identifier for this bubble.
  /// {@endtemplate}
  final String id;

  /// {@template add_chat_head_config.icon_asset}
  /// Flutter asset path for the bubble's icon.
  ///
  /// Prefer using [iconSource] instead for multi-source support.
  /// {@endtemplate}
  final String? iconAsset;

  /// {@template add_chat_head_config.icon_source}
  /// Multi-source icon for the bubble.
  ///
  /// When provided, takes precedence over [iconAsset].
  /// {@endtemplate}
  final IconSource? iconSource;
}
