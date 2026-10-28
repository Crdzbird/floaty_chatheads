part of '../floaty_scope.dart';

final class _FloatyScopeState extends State<FloatyScope> {
  Object? _lastMessage;
  String? _lastTappedId;
  String? _lastClosedId;
  String? _lastExpandedId;
  String? _lastCollapsedId;
  ChatHeadDragEvent? _lastDragStart;
  ChatHeadDragEvent? _lastDragEnd;
  OverlayColorPalette? _palette;
  bool _isMainAppConnected = true;
  final List<Object?> _messages = [];
  final List<StreamSubscription<Object?>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _palette = FloatyOverlay.palette;
    _isMainAppConnected = FloatyConnectionState.isMainAppConnected;
    _listen(FloatyOverlay.onData, (data) {
      _lastMessage = data;
      _messages.add(data);
    });
    _listen(FloatyOverlay.onTapped, (id) => _lastTappedId = id);
    _listen(FloatyOverlay.onClosed, (id) => _lastClosedId = id);
    _listen(FloatyOverlay.onExpanded, (id) => _lastExpandedId = id);
    _listen(FloatyOverlay.onCollapsed, (id) => _lastCollapsedId = id);
    _listen(FloatyOverlay.onDragStart, (event) => _lastDragStart = event);
    _listen(FloatyOverlay.onDragEnd, (event) => _lastDragEnd = event);
    _listen(FloatyOverlay.onPaletteChanged, (palette) => _palette = palette);
    _listen(
      FloatyConnectionState.onConnectionChanged,
      (connected) => _isMainAppConnected = connected,
    );
  }

  void _listen<T>(Stream<T> stream, void Function(T value) apply) {
    _subscriptions.add(
      stream.listen((value) {
        if (!mounted) return;
        setState(() => apply(value));
      }),
    );
  }

  @override
  void dispose() {
    unawaited(Future.wait(_subscriptions.map((s) => s.cancel())));
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FloatyScopeInherited(
    data: FloatyScopeData(
      lastMessage: _lastMessage,
      messages: List.unmodifiable(_messages),
      lastTappedId: _lastTappedId,
      lastClosedId: _lastClosedId,
      lastExpandedId: _lastExpandedId,
      lastCollapsedId: _lastCollapsedId,
      lastDragStart: _lastDragStart,
      lastDragEnd: _lastDragEnd,
      palette: _palette,
      isMainAppConnected: _isMainAppConnected,
    ),
    child: widget.child,
  );
}
