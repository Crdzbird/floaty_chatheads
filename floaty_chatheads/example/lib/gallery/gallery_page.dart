import 'package:flutter/material.dart';

import 'advanced_entries.dart';
import 'core_entries.dart';
import 'gallery_tile.dart';

/// The example gallery: lists every demo and opens it on tap.
final class GalleryPage extends StatelessWidget {
  /// Creates the gallery page.
  const factory GalleryPage({Key? key}) = GalleryPage._;

  const GalleryPage._({super.key});

  static const _entries = [...coreEntries, ...advancedEntries];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floaty Chathead Examples')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) => GalleryTile(entry: _entries[index]),
      ),
    );
  }
}
