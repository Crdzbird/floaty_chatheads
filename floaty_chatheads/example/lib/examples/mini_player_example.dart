import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'mini_player/launch_mini_player.dart';
import 'mini_player/mini_player_now_playing.dart';
import 'mini_player/mini_player_playlist.dart';
import 'mini_player/mini_player_tracks.dart';
import 'mini_player/mini_player_transport.dart';

part 'mini_player/mini_player_example_state.dart';

/// Mini player example: main app has a playlist, overlay shows
/// compact transport controls. State syncs bidirectionally.
final class MiniPlayerExample extends StatefulWidget {
  /// Creates the mini player example page.
  const factory MiniPlayerExample({Key? key}) = MiniPlayerExample._;

  const MiniPlayerExample._({super.key});

  @override
  State<MiniPlayerExample> createState() => _MiniPlayerExampleState();
}
