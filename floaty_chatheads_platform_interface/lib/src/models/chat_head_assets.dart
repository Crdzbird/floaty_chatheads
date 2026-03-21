import 'package:floaty_chatheads_platform_interface/src/models/icon_source.dart';
import 'package:meta/meta.dart';

/// {@template chat_head_assets}
/// Groups the three icon sources needed by a chathead.
///
/// Each field accepts an [IconSource], which can be a Flutter asset path,
/// a network URL, or raw image bytes:
///
/// ```dart
/// // From assets (most common).
/// assets: ChatHeadAssets(
///   icon: IconSource.asset('assets/chatheadIcon.png'),
///   closeIcon: IconSource.asset('assets/close.png'),
///   closeBackground: IconSource.asset('assets/closeBg.png'),
/// ),
///
/// // From a network URL.
/// assets: ChatHeadAssets(
///   icon: IconSource.network('https://example.com/icon.png'),
///   closeIcon: IconSource.asset('assets/close.png'),
///   closeBackground: IconSource.asset('assets/closeBg.png'),
/// ),
///
/// // From raw bytes.
/// assets: ChatHeadAssets(
///   icon: IconSource.bytes(myPngBytes),
///   closeIcon: IconSource.asset('assets/close.png'),
///   closeBackground: IconSource.asset('assets/closeBg.png'),
/// ),
/// ```
///
/// Use [ChatHeadAssets.defaults] for the conventional asset names.
/// {@endtemplate}
@immutable
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
      : icon = const IconSource.asset('assets/chatheadIcon.png'),
        closeIcon = const IconSource.asset('assets/close.png'),
        closeBackground = const IconSource.asset('assets/closeBg.png');

  /// Icon source for the chathead bubble.
  final IconSource icon;

  /// Icon source for the close-button icon.
  final IconSource closeIcon;

  /// Icon source for the close-button background.
  final IconSource closeBackground;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHeadAssets &&
          other.icon == icon &&
          other.closeIcon == closeIcon &&
          other.closeBackground == closeBackground;

  @override
  int get hashCode => Object.hash(icon, closeIcon, closeBackground);
}
