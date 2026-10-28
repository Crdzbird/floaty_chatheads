part of 'icon_source.dart';

/// {@template asset_icon_source}
/// An [IconSource] that loads from a Flutter asset path.
/// {@endtemplate}
final class AssetIconSource extends IconSource {
  /// {@macro asset_icon_source}
  const factory AssetIconSource(String path) = AssetIconSource._;

  const AssetIconSource._(this.path) : super._();

  /// Flutter asset path (e.g. `'assets/chatheadIcon.png'`).
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AssetIconSource && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
