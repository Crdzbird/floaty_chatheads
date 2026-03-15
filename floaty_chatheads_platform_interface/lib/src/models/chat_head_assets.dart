/// {@template chat_head_assets}
/// Groups the three asset paths needed by a chathead.
///
/// Instead of passing `chatheadIconAsset`, `closeIconAsset`, and
/// `closeBackgroundAsset` as separate strings, bundle them here:
///
/// ```dart
/// assets: ChatHeadAssets(
///   icon: 'assets/chatheadIcon.png',
///   closeIcon: 'assets/close.png',
///   closeBackground: 'assets/closeBg.png',
/// ),
/// ```
///
/// Use [ChatHeadAssets.defaults] for the conventional asset names.
/// {@endtemplate}
class ChatHeadAssets {
  /// {@macro chat_head_assets}
  const ChatHeadAssets({
    required this.icon,
    required this.closeIcon,
    required this.closeBackground,
  });

  /// Convention-based defaults that match the example project layout:
  ///
  /// - `assets/chatheadIcon.png`
  /// - `assets/close.png`
  /// - `assets/closeBg.png`
  const ChatHeadAssets.defaults()
      : icon = 'assets/chatheadIcon.png',
        closeIcon = 'assets/close.png',
        closeBackground = 'assets/closeBg.png';

  /// Flutter asset path for the chathead bubble icon.
  final String icon;

  /// Flutter asset path for the close-button icon.
  final String closeIcon;

  /// Flutter asset path for the close-button background.
  final String closeBackground;
}
