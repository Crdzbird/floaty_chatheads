import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Vertical strip of quick-action FABs that collapse/expand on chathead tap.
///
/// Sends the action name back to the main app when tapped.
/// Uses [FloatyOverlayBuilder] to eliminate all lifecycle boilerplate.
class QuickActionOverlay extends StatelessWidget {
  const QuickActionOverlay({super.key});

  static const _actions = [
    _Action(Icons.camera_alt, 'screenshot', Colors.blue),
    _Action(Icons.bookmark, 'bookmark', Colors.orange),
    _Action(Icons.share, 'share', Colors.green),
    _Action(Icons.settings, 'settings', Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayBuilder<bool>(
      initialState: true,
      onData: (expanded, _) => expanded,
      onTapped: (expanded, _) {
        final next = !expanded;
        if (next) {
          FloatyOverlay.resizeContent(200, 300);
        } else {
          FloatyOverlay.resizeContent(60, 60);
        }
        return next;
      },
      builder: (context, expanded) {
        if (!expanded) return const SizedBox.shrink();

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
                        onTap: () => FloatyOverlay.shareData({
                          'action': action.name,
                          'timestamp': DateTime.now().millisecondsSinceEpoch,
                        }),
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
      },
    );
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
