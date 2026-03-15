import 'package:floaty_chatheads_platform_interface/src/models/notification_visibility.dart';

/// {@template notification_config}
/// Groups notification-related parameters for the chathead service.
///
/// ```dart
/// notification: NotificationConfig(
///   title: 'My Overlay',
///   iconAsset: 'assets/notification.png',
///   visibility: NotificationVisibility.visibilityPublic,
/// ),
/// ```
/// {@endtemplate}
class NotificationConfig {
  /// {@macro notification_config}
  const NotificationConfig({
    this.title,
    this.iconAsset,
    this.visibility = NotificationVisibility.visibilityPublic,
  });

  /// Title shown in the foreground-service notification (Android).
  final String? title;

  /// Flutter asset path for the notification icon (Android).
  final String? iconAsset;

  /// Notification visibility on the lock screen (Android).
  ///
  /// Defaults to [NotificationVisibility.visibilityPublic].
  final NotificationVisibility visibility;
}
