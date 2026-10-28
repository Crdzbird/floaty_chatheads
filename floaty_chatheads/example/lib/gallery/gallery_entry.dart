import 'package:flutter/material.dart';

/// One row of the example gallery: how it looks and which page it opens.
@immutable
final class GalleryEntry {
  /// Creates a gallery row that opens [page] when tapped.
  const factory GalleryEntry({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget page,
  }) = GalleryEntry._;

  const GalleryEntry._({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.page,
  });

  /// Title shown in the list tile.
  final String title;

  /// One line summary shown under the title.
  final String description;

  /// Icon shown in the leading avatar.
  final IconData icon;

  /// Background color of the leading avatar.
  final Color color;

  /// Page pushed when the row is tapped.
  final Widget page;
}
