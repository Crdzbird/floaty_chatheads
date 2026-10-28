import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'gallery/gallery_page.dart';
import 'overlays/overlays.dart';

void main() => runApp(const MaterialApp(home: GalleryPage()));

@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(const OverlayContent());

@pragma('vm:entry-point')
void messengerOverlayMain() => FloatyOverlayApp.run(const MessengerOverlay());

@pragma('vm:entry-point')
void miniPlayerOverlayMain() => FloatyOverlayApp.run(const MiniPlayerOverlay());

@pragma('vm:entry-point')
void quickActionOverlayMain() =>
    FloatyOverlayApp.run(const QuickActionOverlay());

@pragma('vm:entry-point')
void counterOverlayMain() =>
    FloatyOverlayApp.run(const NotificationCounterOverlay());

@pragma('vm:entry-point')
void timerOverlayMain() => FloatyOverlayApp.run(const TimerOverlay());

@pragma('vm:entry-point')
void multiChatOverlayMain() => FloatyOverlayApp.run(const MultiChatOverlay());

@pragma('vm:entry-point')
void dashboardOverlayMain() => FloatyOverlayApp.run(const DashboardOverlay());

@pragma('vm:entry-point')
void messengerFullscreenOverlayMain() =>
    FloatyOverlayApp.run(const MessengerFullscreenOverlay());

@pragma('vm:entry-point')
void featuresOverlayMain() =>
    FloatyOverlayApp.run(const FeaturesShowcaseOverlay());

@pragma('vm:entry-point')
void themedOverlayMain() => FloatyOverlayApp.run(const ThemedOverlay());

@pragma('vm:entry-point')
void mapOverlayMain() => FloatyOverlayApp.run(const MapOverlay());

@pragma('vm:entry-point')
void accessibilityOverlayMain() =>
    FloatyOverlayApp.run(const AccessibilityOverlay());

@pragma('vm:entry-point')
void survivalOverlayMain() => FloatyOverlayApp.run(const SurvivalOverlay());

@pragma('vm:entry-point')
void todoSurvivalOverlayMain() =>
    FloatyOverlayApp.run(const TodoSurvivalOverlay());

@pragma('vm:entry-point')
void gpsStreamOverlayMain() => FloatyOverlayApp.run(const GpsStreamOverlay());

@pragma('vm:entry-point')
void sensorStreamOverlayMain() =>
    FloatyOverlayApp.run(const SensorStreamOverlay());

@pragma('vm:entry-point')
void autoLaunchOverlayMain() => FloatyOverlayApp.run(const AutoLaunchOverlay());

@pragma('vm:entry-point')
void widgetIconOverlayMain() => FloatyOverlayApp.run(const WidgetIconOverlay());

@pragma('vm:entry-point')
void panelAnchorOverlayMain() =>
    FloatyOverlayApp.run(const PanelAnchorOverlay());
