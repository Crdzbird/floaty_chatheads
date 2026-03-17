import 'package:floaty_chatheads_platform_interface/src/models/notification_visibility.dart';

/// {@template notification_config}
/// Groups notification-related parameters for the chathead service.
///
/// ```dart
/// notification: NotificationConfig(
///   title: 'My Overlay',
///   description: 'Overlay is active',
///   iconAsset: 'assets/notification.png',
///   visibility: NotificationVisibility.visibilityPublic,
/// ),
/// ```
/// {@endtemplate}
class NotificationConfig {
  /// {@macro notification_config}
  const NotificationConfig({
    this.title,
    this.description,
    this.iconAsset,
    this.visibility = NotificationVisibility.visibilityPublic,
  });

  /// Title shown in the foreground-service notification (Android).
  final String? title;

  /// Body text shown in the foreground-service notification (Android).
  ///
  /// When set, the notification title displays without the default
  /// " is running" suffix and this text appears as the notification body.
  /// When `null`, the default `"<title> is running"` format is used.
  final String? description;

  /// Flutter asset path for the notification icon (Android).
  final String? iconAsset;

  /// Notification visibility on the lock screen (Android).
  ///
  /// Defaults to [NotificationVisibility.visibilityPublic].
  final NotificationVisibility visibility;
}
