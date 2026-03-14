import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Vertical strip of quick-action FABs that collapse/expand on chathead tap.
///
/// Sends the action name back to the main app when tapped.
class QuickActionOverlay extends StatefulWidget {
  const QuickActionOverlay({super.key});

  @override
  State<QuickActionOverlay> createState() => _QuickActionOverlayState();
}

class _QuickActionOverlayState extends State<QuickActionOverlay> {
  bool _expanded = true;
  late final StreamSubscription<String> _tapSub;

  static const _actions = [
    _Action(Icons.camera_alt, 'screenshot', Colors.blue),
    _Action(Icons.bookmark, 'bookmark', Colors.orange),
    _Action(Icons.share, 'share', Colors.green),
    _Action(Icons.settings, 'settings', Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    _tapSub = FloatyOverlay.onTapped.listen((id) {
      setState(() => _expanded = !_expanded);
      if (_expanded) {
        FloatyOverlay.resizeContent(200, 300);
      } else {
        FloatyOverlay.resizeContent(60, 60);
      }
    });
  }

  void _onAction(String action) {
    FloatyOverlay.shareData({'action': action, 'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in _actions) ...[
                  _ActionButton(
                    icon: action.icon,
                    color: action.color,
                    label: action.name,
                    onTap: () => _onAction(action.name),
                  ),
                  const SizedBox(height: 6),
                ],
                _ActionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'close',
                  onTap: FloatyOverlay.closeOverlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tapSub.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

class _Action {
  const _Action(this.icon, this.name, this.color);
  final IconData icon;
  final String name;
  final Color color;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
