import 'dart:async';

import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../models/survival_actions.dart';
import 'survival/survival_connection_banner.dart';
import 'survival/survival_counter_buttons.dart';
import 'survival/survival_counter_display.dart';
import 'survival/survival_overlay_footer.dart';
import 'survival/survival_queue_badge.dart';
import 'survival/survival_server_time_button.dart';

part 'survival/survival_overlay_body.dart';
part 'survival/survival_overlay_body_state.dart';
part 'survival/survival_overlay_logic.dart';

/// Overlay that demonstrates survival after app death using
/// [FloatyOverlayScope] for zero-boilerplate wiring: a connection
/// banner, counter buttons that queue while disconnected, a proxy call
/// with an offline fallback, and state sync from the main app.
final class SurvivalOverlay extends StatelessWidget {
  /// Creates the survival overlay.
  const factory SurvivalOverlay({Key? key}) = SurvivalOverlay._;

  const SurvivalOverlay._({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayScope<SurvivalState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: SurvivalState.fromJson,
      initialState: SurvivalState(),
      builder: (context, kit, state, connected) {
        return _SurvivalOverlayBody(
          kit: kit,
          state: state,
          connected: connected,
        );
      },
    );
  }
}
