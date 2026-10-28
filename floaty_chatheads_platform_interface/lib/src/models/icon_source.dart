import 'dart:typed_data';

import 'package:flutter/foundation.dart' show immutable, listEquals;

part 'asset_icon_source.dart';
part 'bytes_icon_source.dart';
part 'network_icon_source.dart';

/// {@template icon_source}
/// Describes where to load an icon image from.
///
/// Use one of the factory constructors to specify the source:
///
/// ```dart
/// // From a Flutter asset bundled in the app.
/// IconSource.asset('assets/icon.png')
///
/// // From a network URL (downloaded natively on Android).
/// IconSource.network('https://example.com/icon.png')
///
/// // From raw image bytes already in memory.
/// IconSource.bytes(myUint8List)
/// ```
///
/// [AssetIconSource] and [NetworkIconSource] are `const`-constructible,
/// which means they can be used in `const` contexts (e.g.
/// `ChatHeadAssets.defaults()`).
/// {@endtemplate}
@immutable
sealed class IconSource {
  /// {@macro icon_source}
  const IconSource._();

  /// Load an icon from a Flutter asset path.
  ///
  /// The [path] is resolved via `FlutterLoader.getLookupKeyForAsset` on
  /// Android, which supports asset variants.
  const factory IconSource.asset(String path) = AssetIconSource;

  /// Load an icon from a network URL.
  ///
  /// The image is downloaded natively using `HttpURLConnection` on
  /// Android. The download happens on an IO thread and does **not**
  /// block the UI.
  const factory IconSource.network(String url) = NetworkIconSource;

  /// Load an icon from raw image bytes.
  ///
  /// Useful when the image is already decoded in Dart (e.g. generated
  /// programmatically or fetched via an HTTP client on the Dart side).
  const factory IconSource.bytes(Uint8List data) = BytesIconSource;
}
