part of 'icon_source.dart';

/// {@template bytes_icon_source}
/// An [IconSource] that loads from raw image bytes.
/// {@endtemplate}
final class BytesIconSource extends IconSource {
  /// {@macro bytes_icon_source}
  const factory BytesIconSource(Uint8List data) = BytesIconSource._;

  const BytesIconSource._(this.data) : super._();

  /// Raw image bytes (PNG, JPEG, WebP, etc.).
  final Uint8List data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BytesIconSource && listEquals(other.data, data);

  @override
  int get hashCode => Object.hashAll(data);
}
