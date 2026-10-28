part of '../floaty_overlay_scope.dart';

final class _FloatyOverlayScopeState<S> extends State<FloatyOverlayScope<S>> {
  late final FloatyOverlayKit<S> _kit;
  late S _state;
  late bool _connected;

  StreamSubscription<S>? _stateSub;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _kit = FloatyOverlayKit<S>(
      stateToJson: widget.stateToJson,
      stateFromJson: widget.stateFromJson,
      initialState: widget.initialState,
      maxQueueSize: widget.maxQueueSize,
      overflowStrategy: widget.overflowStrategy,
      proxyTimeout: widget.proxyTimeout,
    );
    _state = widget.initialState;
    _connected = _kit.isConnected;
    _stateSub = _kit.onStateChanged.listen((state) {
      if (mounted) setState(() => _state = state);
    });
    _connSub = _kit.onConnectionChanged.listen((connected) {
      if (mounted) setState(() => _connected = connected);
    });
  }

  @override
  Widget build(BuildContext context) => _FloatyOverlayScopeInherited<S>(
    kit: _kit,
    child: widget.builder(context, _kit, _state, _connected),
  );

  @override
  void dispose() {
    unawaited(_tearDown());
    super.dispose();
  }

  Future<void> _tearDown() async {
    await Future.wait([
      if (_stateSub != null) _stateSub!.cancel(),
      if (_connSub != null) _connSub!.cancel(),
      _kit.dispose(),
    ]);
    FloatyOverlay.dispose();
  }
}
