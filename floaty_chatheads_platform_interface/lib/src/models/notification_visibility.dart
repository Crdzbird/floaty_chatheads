/// {@template notification_visibility}
/// Visibility level of the foreground-service notification (Android).
/// {@endtemplate}
enum NotificationVisibility {
  /// {@template notification_visibility.public}
  /// Show the notification on all lock screens.
  /// {@endtemplate}
  visibilityPublic,

  /// {@template notification_visibility.secret}
  /// Hide sensitive content on secure lock screens.
  /// {@endtemplate}
  visibilitySecret,

  /// {@template notification_visibility.private}
  /// Show the notification but conceal sensitive fields.
  /// {@endtemplate}
  visibilityPrivate,
}
