import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test helpers ─────────────────────────────────────────────────────

class _IncrementAction extends FloatyAction {
  _IncrementAction({required this.amount});

  factory _IncrementAction.fromJson(Map<String, dynamic> json) =>
      _IncrementAction(amount: json['amount'] as int);

  final int amount;

  @override
  String get type => 'increment';

  @override
  Map<String, dynamic> toJson() => {'amount': amount};
}

class _TestState {
  _TestState({this.counter = 0, this.label = 'ready'});

  factory _TestState.fromJson(Map<String, dynamic> json) => _TestState(
        counter: json['counter'] as int? ?? 0,
        label: json['label'] as String? ?? 'ready',
      );

  final int counter;
  final String label;

  Map<String, dynamic> toJson() => {'counter': counter, 'label': label};
}

Future<void> _simulateMessage(Object? data) async {
  final encoded = const JSONMessageCodec().encodeMessage(data);
  await TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'ni.devotion.floaty_head/messenger',
    encoded,
    (data) {},
  );
  await Future<void>.delayed(Duration.zero);
}

// ── Tests ────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(FloatyChannel.dispose);

  group('FloatyHostKit', () {
    late FloatyHostKit<_TestState> kit;

    setUp(() {
      kit = FloatyHostKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
    });

    tearDown(() => kit.dispose());

    test('constructor creates all components', () {
      expect(kit.router, isA<FloatyActionRouter>());
      expect(kit.stateChannel, isA<FloatyStateChannel<_TestState>>());
      expect(kit.proxyHost, isA<FloatyProxyHost>());
    });

    test('onAction/offAction delegates to router', () async {
      var received = false;
      kit.onAction<_IncrementAction>(
        'increment',
        fromJson: _IncrementAction.fromJson,
        handler: (_) => received = true,
      );

      await _simulateMessage({
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 1},
        },
      });

      expect(received, isTrue);

      // After offAction, the handler should be removed.
      kit.offAction('increment');
      received = false;

      await _simulateMessage({
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 2},
        },
      });

      expect(received, isFalse);
    });

    test('setState/state delegates to stateChannel', () async {
      expect(kit.state.counter, 0);

      await kit.setState(_TestState(counter: 42, label: 'updated'));

      expect(kit.state.counter, 42);
      expect(kit.state.label, 'updated');
    });

    test('onStateChanged emits on remote update', () async {
      final states = <_TestState>[];
      kit.onStateChanged.listen(states.add);

      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'counter': 7, 'label': 'remote'},
        },
      });

      expect(states, hasLength(1));
      expect(states.first.counter, 7);
    });

    test('updateState performs shallow merge', () async {
      await kit.setState(_TestState(counter: 10, label: 'before'));
      await kit.updateState({'counter': 20});

      expect(kit.state.counter, 20);
      expect(kit.state.label, 'before'); // Preserved.
    });

    test('registerService handles proxy requests', () async {
      kit.registerService('echo', (method, params) {
        return {'echoed': method};
      });

      // Simulate a proxy request from the overlay.
      await _simulateMessage({
        '_floaty_proxy': {
          'type': 'request',
          'id': '42',
          'service': 'echo',
          'method': 'ping',
          'params': <String, dynamic>{},
        },
      });

      // No crash means the service was invoked.
    });

    test('unregisterService removes service', () {
      kit
        ..registerService('temp', (_, __) => null)
        ..unregisterService('temp');
      // No crash, service removed.
    });

    test('dispatch does not throw', () async {
      await kit.dispatch(_IncrementAction(amount: 5));
    });

    test('queueLength is always 0 on host side', () async {
      expect(kit.queueLength, 0);
      await kit.dispatch(_IncrementAction(amount: 1));
      expect(kit.queueLength, 0);
    });

    test('dispose tears down all components', () async {
      kit.dispose();

      // After dispose, prefixed messages should flow to rawMessages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 1},
        },
      });

      expect(rawReceived, hasLength(1));
    });
  });

  group('FloatyOverlayKit', () {
    setUp(() {
      FloatyConnectionState.dispose();
      FloatyConnectionState.setUp();
    });

    tearDown(FloatyConnectionState.dispose);

    test('constructor creates overlay-side components', () {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.router, isA<FloatyActionRouter>());
      expect(kit.stateChannel, isA<FloatyStateChannel<_TestState>>());
      expect(kit.proxyClient, isA<FloatyProxyClient>());
    });

    test('isConnected delegates to FloatyConnectionState', () async {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      // Default is connected.
      expect(kit.isConnected, isTrue);

      // Simulate disconnect.
      await _simulateMessage({
        '_floaty_connection': {'connected': false},
      });

      expect(kit.isConnected, isFalse);
    });

    test('onConnectionChanged emits on state change', () async {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      final events = <bool>[];
      kit.onConnectionChanged.listen(events.add);

      await _simulateMessage({
        '_floaty_connection': {'connected': false},
      });

      expect(events, contains(false));
    });

    test('dispatch queues when disconnected', () async {
      await _simulateMessage({
        '_floaty_connection': {'connected': false},
      });

      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      await kit.dispatch(_IncrementAction(amount: 1));
      await kit.dispatch(_IncrementAction(amount: 2));

      expect(kit.queueLength, 2);
    });

    test('callService returns fallback when disconnected', () async {
      await _simulateMessage({
        '_floaty_connection': {'connected': false},
      });

      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      final result = await kit.callService(
        'time',
        'now',
        fallback: () => 'offline',
      );

      expect(result, 'offline');
    });

    test('callService throws when disconnected without fallback', () async {
      await _simulateMessage({
        '_floaty_connection': {'connected': false},
      });

      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      expect(
        () => kit.callService('time', 'now'),
        throwsA(isA<FloatyProxyDisconnectedException>()),
      );
    });

    test('state and onStateChanged delegate correctly', () async {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.state.counter, 0);

      final states = <_TestState>[];
      kit.onStateChanged.listen(states.add);

      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'counter': 99, 'label': 'synced'},
        },
      });

      expect(states, hasLength(1));
      expect(states.first.counter, 99);
      expect(kit.state.counter, 99);
    });

    test('onAction/offAction delegates to router', () async {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      var received = false;
      kit.onAction<_IncrementAction>(
        'increment',
        fromJson: _IncrementAction.fromJson,
        handler: (_) => received = true,
      );

      await _simulateMessage({
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 1},
        },
      });

      expect(received, isTrue);

      // After offAction, the handler should be removed.
      kit.offAction('increment');
      received = false;

      await _simulateMessage({
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 2},
        },
      });

      expect(received, isFalse);
    });

    test('setState delegates to stateChannel', () async {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      expect(kit.state.counter, 0);

      await kit.setState(_TestState(counter: 42, label: 'updated'));

      expect(kit.state.counter, 42);
      expect(kit.state.label, 'updated');
    });

    test('updateState performs shallow merge', () async {
      final kit = FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      );
      addTearDown(kit.dispose);

      await kit.setState(_TestState(counter: 10, label: 'before'));
      await kit.updateState({'counter': 20});

      expect(kit.state.counter, 20);
      expect(kit.state.label, 'before'); // Preserved.
    });

    test('dispose tears down all overlay components', () async {
      FloatyOverlayKit<_TestState>(
        stateToJson: (s) => s.toJson(),
        stateFromJson: _TestState.fromJson,
        initialState: _TestState(),
      ).dispose();

      // After dispose, prefixed messages should flow to rawMessages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '_floaty_action': {
          'type': 'increment',
          'payload': {'amount': 1},
        },
      });

      expect(rawReceived, hasLength(1));
    });
  });
}
