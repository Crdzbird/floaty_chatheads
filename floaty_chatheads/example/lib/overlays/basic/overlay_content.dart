import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'last_received_box.dart';

part 'overlay_content_state.dart';

/// Basic overlay: shows the last payload from the main app and sends data
/// back, wrapped in a [FloatySimplePanel].
final class OverlayContent extends StatefulWidget {
  /// Creates the basic overlay.
  const factory OverlayContent({Key? key}) = OverlayContent._;

  const OverlayContent._({super.key});

  @override
  State<OverlayContent> createState() => _OverlayContentState();
}
