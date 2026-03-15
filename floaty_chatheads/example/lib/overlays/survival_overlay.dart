import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../models/survival_actions.dart';

/// Overlay that demonstrates survival after app death using
/// [FloatyOverlayScope] for zero-boilerplate wiring:
///
/// - **Connection banner** — green when connected, red when the main
///   app is killed.
/// - **Counter buttons** — dispatch `IncrementAction` via the kit.
///   When disconnected, actions are queued (badge shows count).
/// - **Server Time** — calls a proxy service. Returns a fallback
///   string when disconnected instead of timing out.
/// - **State sync** — receives counter updates from the main app.
///
/// No manual subscriptions, no dispose calls — `FloatyOverlayScope`
/// manages everything.
class SurvivalOverlay extends StatelessWidget {
  const SurvivalOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayScope<SurvivalState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: SurvivalState.fromJson,
      initialState: SurvivalState(),
      builder: (context, kit, state, connected) {
        return _SurvivalOverlayContent(
          kit: kit,
          state: state,
          connected: connected,
        );
      },
    );
  }
}

/// Stateful content widget that manages local-only UI state
/// (proxy result, optimistic counter) while receiving reactive
/// state and connection updates from [FloatyOverlayScope].
class _SurvivalOverlayContent extends StatefulWidget {
  const _SurvivalOverlayContent({
    required this.kit,
    required this.state,
    required this.connected,
  });

  final FloatyOverlayKit<SurvivalState> kit;
  final SurvivalState state;
  final bool connected;

  @override
  State<_SurvivalOverlayContent> createState() =>
      _SurvivalOverlayContentState();
}

class _SurvivalOverlayContentState
    extends State<_SurvivalOverlayContent> {
  String _lastProxyResult = '';
  int _optimisticDelta = 0;

  int get _displayCounter =>
      widget.state.counter + _optimisticDelta;

  void _increment(int amount) {
    widget.kit.dispatch(IncrementAction(amount: amount));
    // Optimistically update the local counter.
    setState(() => _optimisticDelta += amount);
  }

  void _sendMessage() {
    widget.kit.dispatch(MessageAction(
      text: 'Hello from overlay! '
          '(queued: ${widget.kit.queueLength})',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> _getServerTime() async {
    try {
      final result = await widget.kit.callService(
        'time',
        'now',
        fallback: () => {'iso': 'N/A (offline)', 'millis': 0},
      );
      if (result is Map && mounted) {
        setState(() {
          _lastProxyResult = '${result['iso']}';
        });
      }
    } on FloatyProxyException catch (e) {
      if (mounted) {
        setState(() => _lastProxyResult = 'Error: $e');
      }
    }
  }

  @override
  void didUpdateWidget(_SurvivalOverlayContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset optimistic delta when we receive a new state from host.
    if (oldWidget.state.counter != widget.state.counter) {
      _optimisticDelta = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueCount = widget.kit.queueLength;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Connection banner ──
              _ConnectionBanner(connected: widget.connected),

              // ── Counter display ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Text(
                      '$_displayCounter',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: widget.connected
                            ? Colors.deepOrange
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      widget.state.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Counter buttons ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    _ActionButton(
                      label: '+1',
                      onTap: () => _increment(1),
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 6),
                    _ActionButton(
                      label: '+5',
                      onTap: () => _increment(5),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    _ActionButton(
                      label: '+10',
                      onTap: () => _increment(10),
                      color: Colors.amber.shade700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Queue badge ──
              if (queueCount > 0)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.queue,
                        size: 12,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$queueCount queued',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ── Proxy: Server Time ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: GestureDetector(
                  onTap: _getServerTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Get Server Time',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (_lastProxyResult.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _lastProxyResult,
                            style: TextStyle(
                              fontSize: 8,
                              color: _lastProxyResult
                                      .contains('offline')
                                  ? Colors.red.shade400
                                  : Colors.blue.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Send message & close ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Send Message',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      color: connected ? Colors.green : Colors.red.shade700,
      child: Row(
        children: [
          Icon(
            connected ? Icons.link : Icons.link_off,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              connected ? 'Connected' : 'Disconnected',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          if (!connected)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'OFFLINE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (connected)
            GestureDetector(
              onTap: FloatyOverlay.closeOverlay,
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 13,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
