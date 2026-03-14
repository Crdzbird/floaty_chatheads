import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Simple overlay for accessibility testing with TalkBack.
///
/// Uses semantic labels and large touch targets for screen-reader friendliness.
class AccessibilityOverlay extends StatefulWidget {
  const AccessibilityOverlay({super.key});

  @override
  State<AccessibilityOverlay> createState() => _AccessibilityOverlayState();
}

class _AccessibilityOverlayState extends State<AccessibilityOverlay> {
  int _tapCount = 0;
  StreamSubscription<Object?>? _dataSub;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _dataSub = FloatyOverlay.onData.listen((data) {
      if (mounted) setState(() => _lastMessage = '$data');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: 'Accessibility test overlay',
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    header: true,
                    child: const Text(
                      'Accessibility Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'Tapped $_tapCount times',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_lastMessage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Semantics(
                      label: 'Last message from main app',
                      child: Text(
                        _lastMessage,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Large touch target for accessibility
                  Semantics(
                    button: true,
                    label: 'Tap counter button',
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _tapCount++);
                        FloatyOverlay.shareData({
                          'action': 'tap',
                          'count': _tapCount,
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tap Me',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    button: true,
                    label: 'Close overlay',
                    child: GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Close',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
