import 'dart:math';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Demonstrates widget-based chathead icons — static, animated, and
/// custom close icons — all without image assets.
class WidgetIconExample extends StatefulWidget {
  const WidgetIconExample({super.key});

  @override
  State<WidgetIconExample> createState() => _WidgetIconExampleState();
}

class _WidgetIconExampleState extends State<WidgetIconExample> {
  bool _animating = false;

  // ── 1. Static widget icon ───────────────────────────────────────

  Future<void> _launchStaticWidget() async {
    if (!await ensureOverlayPermission()) return;

    await FloatyChatheads.showChatHead(
      entryPoint: 'widgetIconOverlayMain',
      // Any widget becomes the chathead icon — no image asset needed.
      iconWidget: const CircleAvatar(
        backgroundColor: Colors.indigo,
        child: Text(
          'JD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Close icons as widgets too.
      closeIconWidget: const Icon(Icons.close, color: Colors.white, size: 28),
      closeBackgroundWidget: const DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: SizedBox.expand(),
      ),
      contentWidth: 200,
      contentHeight: 160,
      notification: const NotificationConfig(title: 'Widget Icon Active'),
    );
  }

  // ── 2. Container / Icon widget ──────────────────────────────────

  Future<void> _launchContainerIcon() async {
    if (!await ensureOverlayPermission()) return;

    await FloatyChatheads.showChatHead(
      entryPoint: 'widgetIconOverlayMain',
      iconWidget: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.phone, color: Colors.white, size: 36),
        ),
      ),
      closeIconWidget: const Icon(
        Icons.cancel,
        color: Colors.white,
        size: 32,
      ),
      closeBackgroundWidget: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
        ),
      ),
      contentWidth: 200,
      contentHeight: 160,
      notification: const NotificationConfig(title: 'Gradient Icon Active'),
    );
  }

  // ── 3. Animated widget icon ─────────────────────────────────────

  Future<void> _launchAnimatedIcon() async {
    if (!await ensureOverlayPermission()) return;

    await FloatyChatheads.showChatHead(
      entryPoint: 'widgetIconOverlayMain',
      // The builder receives a 0.0–1.0 animation value each frame.
      iconBuilder: (value) => Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.teal,
        ),
        child: Center(
          child: Transform.rotate(
            angle: value * 2 * pi,
            child: const Icon(Icons.sync, color: Colors.white, size: 40),
          ),
        ),
      ),
      animateIcon: true, // <── boolean to enable animation
      iconAnimationFps: 24,
      iconAnimationDuration: const Duration(seconds: 2),
      closeIconWidget: const Icon(
        Icons.delete_forever,
        color: Colors.white,
        size: 28,
      ),
      closeBackgroundWidget: const DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
        child: SizedBox.expand(),
      ),
      contentWidth: 200,
      contentHeight: 160,
      notification: const NotificationConfig(title: 'Animated Icon Active'),
    );

    setState(() => _animating = true);
  }

  // ── 4. Pulsing notification dot ─────────────────────────────────

  Future<void> _launchPulsingDot() async {
    if (!await ensureOverlayPermission()) return;

    await FloatyChatheads.showChatHead(
      entryPoint: 'widgetIconOverlayMain',
      iconBuilder: (value) {
        // Ping-pong: 0→1→0 for a smooth pulse.
        final pulse = (value < 0.5) ? value * 2 : 2 - value * 2;
        final scale = 0.85 + pulse * 0.15;
        final opacity = 0.6 + pulse * 0.4;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4 * pulse),
                    blurRadius: 12 * pulse,
                    spreadRadius: 4 * pulse,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.priority_high, color: Colors.white, size: 36),
              ),
            ),
          ),
        );
      },
      animateIcon: true,
      iconAnimationFps: 20,
      iconAnimationDuration: const Duration(milliseconds: 1200),
      contentWidth: 200,
      contentHeight: 160,
      notification: const NotificationConfig(title: 'Pulsing Dot Active'),
    );

    setState(() => _animating = true);
  }

  // ── 5. Custom close target widget ────────────────────────────────

  Future<void> _launchCustomClose() async {
    if (!await ensureOverlayPermission()) return;

    await FloatyChatheads.showChatHead(
      entryPoint: 'widgetIconOverlayMain',
      iconWidget: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueGrey,
        ),
        child: const Center(
          child: Icon(Icons.chat, color: Colors.white, size: 36),
        ),
      ),
      // The close icon is a full widget — it fills the close target.
      closeIconWidget: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.red.shade700, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.delete_outline, color: Colors.white, size: 32),
        ),
      ),
      // The background is drawn behind the close icon; use a subtle
      // ring so the close target pops off the screen.
      closeBackgroundWidget: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
          color: Colors.black26,
        ),
      ),
      contentWidth: 200,
      contentHeight: 160,
      notification: const NotificationConfig(title: 'Custom Close Active'),
    );
  }

  // ── Toggle animation ────────────────────────────────────────────

  void _toggleAnimation() {
    if (FloatyChatheads.isIconAnimating) {
      FloatyChatheads.stopIconAnimation();
      setState(() => _animating = false);
    } else {
      FloatyChatheads.startIconAnimation();
      setState(() => _animating = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Icons')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Static widgets
          Text(
            'Static Widget Icons',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: const CircleAvatar(
              backgroundColor: Colors.indigo,
              radius: 20,
              child: Text('JD', style: TextStyle(color: Colors.white)),
            ),
            title: 'Text Avatar',
            subtitle: 'CircleAvatar with initials — no image needed',
            onTap: _launchStaticWidget,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepOrange],
                ),
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 20),
            ),
            title: 'Gradient + Icon',
            subtitle: 'Container with gradient and Material Icon',
            onTap: _launchContainerIcon,
          ),

          const SizedBox(height: 8),
          _Tile(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.orange],
                ),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: 'Custom Close Target',
            subtitle: 'Widget-based close icon with gradient background',
            onTap: _launchCustomClose,
          ),

          const SizedBox(height: 24),

          // Section: Animated widgets
          Text(
            'Animated Widget Icons',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: const CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 20,
              child: Icon(Icons.sync, color: Colors.white),
            ),
            title: 'Spinning Sync',
            subtitle: 'Rotates continuously at 24 fps',
            onTap: _launchAnimatedIcon,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: CircleAvatar(
              backgroundColor: Colors.red.shade400,
              radius: 20,
              child: const Icon(Icons.priority_high, color: Colors.white),
            ),
            title: 'Pulsing Alert',
            subtitle: 'Scale + opacity pulse with glow shadow',
            onTap: _launchPulsingDot,
          ),

          const SizedBox(height: 24),

          // Section: Controls
          Text(
            'Animation Controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _toggleAnimation,
                  icon: Icon(_animating ? Icons.pause : Icons.play_arrow),
                  label: Text(_animating ? 'Pause Animation' : 'Resume'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    FloatyChatheads.closeChatHead();
                    setState(() => _animating = false);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    FloatyChatheads.closeChatHead();
    super.dispose();
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: icon,
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.launch),
        onTap: onTap,
      ),
    );
  }
}
