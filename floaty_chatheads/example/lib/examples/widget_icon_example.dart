import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'widget_icon/launch_custom_close.dart';
import 'widget_icon/launch_gradient_icon.dart';
import 'widget_icon/launch_pulsing_alert.dart';
import 'widget_icon/launch_spinning_sync.dart';
import 'widget_icon/launch_text_avatar.dart';
import 'widget_icon/widget_icon_animated_section.dart';
import 'widget_icon/widget_icon_controls.dart';
import 'widget_icon/widget_icon_static_section.dart';

part 'widget_icon/widget_icon_example_state.dart';

/// Demonstrates widget-based chathead icons: static, animated, and
/// custom close icons, all without image assets.
final class WidgetIconExample extends StatefulWidget {
  /// Creates the widget icon example page.
  const factory WidgetIconExample({Key? key}) = WidgetIconExample._;

  const WidgetIconExample._({super.key});

  @override
  State<WidgetIconExample> createState() => _WidgetIconExampleState();
}
