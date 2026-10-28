import 'package:flutter/material.dart';

import '../examples/examples.dart';
import 'gallery_entry.dart';

/// The last ten gallery rows: theming, proxies, survival and icons.
const advancedEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Themed Chathead',
    description:
        'Custom badge colors, bubble border, close tint, overlay palette.',
    icon: Icons.palette,
    color: Colors.deepPurple,
    page: ThemedExample(),
  ),
  GalleryEntry(
    title: 'Accessibility / TalkBack',
    description:
        'TalkBack testing with semantic labels and large touch targets.',
    icon: Icons.accessibility_new,
    color: Colors.blue,
    page: AccessibilityExample(),
  ),
  GalleryEntry(
    title: 'Interactive Map',
    description: 'OSM map with action routing, state sync, and proxy features.',
    icon: Icons.map,
    color: Colors.green,
    page: MapExample(),
  ),
  GalleryEntry(
    title: 'Overlay Survival',
    description: 'Kill the app: overlay survives, queues actions, reconnects.',
    icon: Icons.shield,
    color: Colors.deepOrange,
    page: SurvivalExample(),
  ),
  GalleryEntry(
    title: 'Todo Survival',
    description:
        'Todo list that survives app death: add, toggle, remove while offline.',
    icon: Icons.checklist,
    color: Colors.teal,
    page: TodoSurvivalExample(),
  ),
  GalleryEntry(
    title: 'GPS Proxy Stream',
    description: 'One-way push: main app streams simulated GPS to the overlay.',
    icon: Icons.gps_fixed,
    color: Colors.green,
    page: GpsStreamExample(),
  ),
  GalleryEntry(
    title: 'Sensor Proxy Streams',
    description:
        'Multiple proxy streams: accelerometer + light sensor at 5 Hz.',
    icon: Icons.sensors,
    color: Colors.purple,
    page: SensorStreamExample(),
  ),
  GalleryEntry(
    title: 'Auto-Launch & Persist',
    description:
        'Chathead auto-shows on background, optionally survives app kill.',
    icon: Icons.auto_awesome,
    color: Colors.indigo,
    page: AutoLaunchExample(),
  ),
  GalleryEntry(
    title: 'Widget Icons',
    description:
        'Use any Flutter widget as chathead/close icon, static or animated.',
    icon: Icons.widgets,
    color: Colors.deepPurple,
    page: WidgetIconExample(),
  ),
  GalleryEntry(
    title: 'Panel Anchor Playground',
    description:
        'NEW in 2.1.0: open the panel below, above, or auto-flip, '
        'with live position reporting and anchored resize.',
    icon: Icons.swap_vert,
    color: Colors.pink,
    page: PanelAnchorExample(),
  ),
];
