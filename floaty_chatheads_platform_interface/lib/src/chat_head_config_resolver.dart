import 'package:floaty_chatheads_platform_interface/src/models/chat_head_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/notification_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/notification_visibility.dart';
import 'package:floaty_chatheads_platform_interface/src/models/snap_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/snap_edge.dart';

/// Platform-agnostic default values and resolution helpers for
/// [ChatHeadConfig] fields.
///
/// Platform implementations (Android, iOS) call these from inside their
/// `showChatHead` method to eliminate duplicated default fallbacks and
/// size-preset arithmetic.
///
/// Pigeon enum/message construction stays in each platform package
/// because the Pigeon types are platform-specific.
abstract final class ChatHeadConfigResolver {
  /// Default value for `SnapConfig.margin` when the caller leaves it null.
  ///
  /// `-10.0` matches the historical native default before snap configs were
  /// introduced.
  static const double defaultSnapMargin = -10;

  /// Returns the effective `(width, height)` after applying any
  /// [ChatHeadConfig.sizePreset]. Falls back to the raw
  /// `contentWidth`/`contentHeight` when no preset is provided.
  static ({int? width, int? height}) contentSize(ChatHeadConfig config) => (
        width: config.sizePreset?.width ?? config.contentWidth,
        height: config.sizePreset?.height ?? config.contentHeight,
      );

  /// Effective snap edge, defaulting to [SnapEdge.both].
  static SnapEdge snapEdge(SnapConfig? snap) => snap?.edge ?? SnapEdge.both;

  /// Effective snap margin, defaulting to [defaultSnapMargin].
  static double snapMargin(SnapConfig? snap) =>
      snap?.margin ?? defaultSnapMargin;

  /// Effective `persistPosition` flag, defaulting to `false`.
  static bool persistPosition(SnapConfig? snap) =>
      snap?.persistPosition ?? false;

  /// Effective notification visibility, defaulting to
  /// [NotificationVisibility.visibilityPublic].
  static NotificationVisibility notificationVisibility(
    NotificationConfig? n,
  ) =>
      n?.visibility ?? NotificationVisibility.visibilityPublic;
}
