import 'package:flutter/material.dart';

import 'gallery_entry.dart';

/// A card in the gallery list that opens the entry's page on tap.
final class GalleryTile extends StatelessWidget {
  /// Creates a tile for [entry].
  const factory GalleryTile({required GalleryEntry entry, Key? key}) =
      GalleryTile._;

  const GalleryTile._({required this.entry, super.key});

  /// The entry this tile shows.
  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.color,
          child: Icon(entry.icon, color: Colors.white),
        ),
        title: Text(entry.title),
        subtitle: Text(entry.description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => entry.page),
          );
        },
      ),
    );
  }
}
