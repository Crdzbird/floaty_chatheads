import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'fullscreen_colors.dart';
import 'fullscreen_contact_status.dart';
import 'fullscreen_header_avatar.dart';
import 'fullscreen_round_icon.dart';

/// Header with the contact avatar, name, status and call and close icons.
final class FullscreenProfileHeader extends StatelessWidget {
  /// Creates the profile header.
  const factory FullscreenProfileHeader({Key? key}) = FullscreenProfileHeader._;

  const FullscreenProfileHeader._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: fullscreenHeaderBg,
        border: Border(bottom: BorderSide(color: fullscreenBorder)),
      ),
      child: Row(
        children: [
          const FullscreenHeaderAvatar(),
          const SizedBox(width: 12),
          const Expanded(child: FullscreenContactStatus()),
          FullscreenRoundIcon(
            icon: Icons.phone_rounded,
            color: fullscreenMessengerBlue,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          FullscreenRoundIcon(
            icon: Icons.videocam_rounded,
            color: fullscreenMessengerBlue,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          FullscreenRoundIcon(
            icon: Icons.close_rounded,
            color: fullscreenTextLight,
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
          ),
        ],
      ),
    );
  }
}
