import 'package:flutter/material.dart';

import '../examples/examples.dart';
import 'gallery_entry.dart';

/// The first ten gallery rows: the core chathead demos.
const coreEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Basic (Original)',
    description: 'Simple chathead with show, close, and send data buttons.',
    icon: Icons.bubble_chart,
    color: Colors.teal,
    page: HomePage(),
  ),
  GalleryEntry(
    title: 'Messenger Chat',
    description: 'Bidirectional messaging between main app and overlay.',
    icon: Icons.chat,
    color: Colors.indigo,
    page: MessengerExample(),
  ),
  GalleryEntry(
    title: 'Mini Player',
    description: 'Media transport controls with state sync.',
    icon: Icons.music_note,
    color: Colors.deepPurple,
    page: MiniPlayerExample(),
  ),
  GalleryEntry(
    title: 'Quick Actions',
    description: 'Click-through FAB buttons with action logging.',
    icon: Icons.bolt,
    color: Colors.orange,
    page: QuickActionExample(),
  ),
  GalleryEntry(
    title: 'Notification Counter',
    description: 'Reactive badge that updates from main app data.',
    icon: Icons.notifications,
    color: Colors.red,
    page: NotificationCounterExample(),
  ),
  GalleryEntry(
    title: 'Timer / Stopwatch',
    description: 'Persistent timer with dynamic resize and lap tracking.',
    icon: Icons.timer,
    color: Colors.blueGrey,
    page: TimerExample(),
  ),
  GalleryEntry(
    title: 'Multi-Chathead',
    description: 'Multiple bubbles that expand in a row (Messenger-style).',
    icon: Icons.group,
    color: Colors.cyan,
    page: MultiChatheadExample(),
  ),
  GalleryEntry(
    title: 'Dashboard (Fullscreen)',
    description: 'Near-fullscreen scrollable notes overlay with rich content.',
    icon: Icons.dashboard,
    color: Colors.blue,
    page: DashboardExample(),
  ),
  GalleryEntry(
    title: 'Messenger (Fullscreen)',
    description: 'Facebook Messenger-style: bubble at top, full chat below.',
    icon: Icons.mark_chat_read,
    color: Color(0xFF0084FF),
    page: MessengerFullscreenExample(),
  ),
  GalleryEntry(
    title: 'Features Showcase',
    description: 'Badge count, programmatic expand/collapse, lifecycle events.',
    icon: Icons.science,
    color: Colors.amber,
    page: FeaturesShowcaseExample(),
  ),
];
