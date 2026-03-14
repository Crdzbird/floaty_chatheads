/// {@template add_chat_head_config}
/// Configuration for adding a chathead bubble to an existing group.
/// {@endtemplate}
class AddChatHeadConfig {
  /// {@macro add_chat_head_config}
  const AddChatHeadConfig({required this.id, this.iconAsset});

  /// {@template add_chat_head_config.id}
  /// Unique identifier for this bubble.
  /// {@endtemplate}
  final String id;

  /// {@template add_chat_head_config.icon_asset}
  /// Flutter asset path for the bubble's icon.
  /// {@endtemplate}
  final String? iconAsset;
}
