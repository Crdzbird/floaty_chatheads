part of 'icon_source.dart';

/// {@template network_icon_source}
/// An [IconSource] that loads from a network URL.
/// {@endtemplate}
final class NetworkIconSource extends IconSource {
  /// {@macro network_icon_source}
  const factory NetworkIconSource(String url) = NetworkIconSource._;

  const NetworkIconSource._(this.url) : super._();

  /// Fully-qualified URL of the image to download.
  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NetworkIconSource && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
