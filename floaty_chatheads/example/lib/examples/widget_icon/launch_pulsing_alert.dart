import 'package:floaty_chatheads/floaty_chatheads.dart';

import '../../utils.dart';
import 'widget_icon_pulse.dart';

/// Shows a chathead whose icon pulses in scale, opacity and glow.
///
/// Returns `false` when the overlay permission was not granted.
Future<bool> launchWidgetIconPulsingAlert() async {
  if (!await ensureOverlayPermission()) return false;

  await FloatyChatheads.showChatHead(
    entryPoint: 'widgetIconOverlayMain',
    iconBuilder: (value) => WidgetIconPulse(value: value),
    animateIcon: true,
    iconAnimationFps: 20,
    iconAnimationDuration: const Duration(milliseconds: 1200),
    contentWidth: 200,
    contentHeight: 160,
    notification: const NotificationConfig(title: 'Pulsing Dot Active'),
  );
  return true;
}
