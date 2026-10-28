part of '../floaty_permission_gate.dart';

final class _FloatyPermissionGateState extends State<FloatyPermissionGate>
    with WidgetsBindingObserver {
  bool _granted = false;
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _granted) return;
    unawaited(_checkPermission());
  }

  Future<void> _checkPermission() async {
    final granted = await FloatyChatheads.checkPermission();
    if (!mounted) return;
    setState(() {
      _granted = granted;
      _loading = false;
    });
    if (granted) {
      _pollTimer?.cancel();
      widget.onPermissionGranted?.call();
      return;
    }
    widget.onPermissionDenied?.call();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer(widget.checkInterval, () => unawaited(_poll()));
  }

  Future<void> _poll() async {
    if (_granted || !mounted) return;
    await _checkPermission();
    if (!_granted && mounted) _startPolling();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    return _granted ? widget.child : widget.fallback;
  }
}
