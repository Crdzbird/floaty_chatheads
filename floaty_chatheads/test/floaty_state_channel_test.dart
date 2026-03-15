import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestState {
  _TestState({this.count = 0, this.label = ''});

  factory _TestState.fromJson(Map<String, dynamic> json) => _TestState(
        count: json['count'] as int? ?? 0,
        label: json['label'] as String? ?? '',
      );

  final int count;
  final String label;

  Map<String, dynamic> toJson() => {'count': count, 'label': label};
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheads.dispose();
    FloatyOverlay.dispose();
    FloatyChannel.dispose();
  });

  group('FloatyStateChannel', () {
    test('setState sends a full state message through the channel', () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(),
      );

      // setState should not throw.
      await channel.setState(_TestState(count: 5, label: 'hello'));

      // Local state should be updated.
      expect(channel.state.count, 5);
      expect(channel.state.label, 'hello');

      channel.dispose();
    });

    test('updateState sends a partial message and updates local state',
        () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(count: 1, label: 'start'),
      );

      await channel.updateState({'count': 10});

      // count updated, label preserved.
      expect(channel.state.count, 10);
      expect(channel.state.label, 'start');

      channel.dispose();
    });

    test('receiving a full state updates the state getter', () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(),
      );

      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'count': 42, 'label': 'received'},
        },
      });

      expect(channel.state.count, 42);
      expect(channel.state.label, 'received');

      channel.dispose();
    });

    test('receiving a partial state merges correctly (shallow merge)',
        () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(count: 5, label: 'original'),
      );

      // Partial update: only change label.
      await _simulateMessage({
        '_floaty_state': {
          'full': false,
          'data': {'label': 'updated'},
        },
      });

      expect(channel.state.count, 5); // preserved
      expect(channel.state.label, 'updated'); // updated

      channel.dispose();
    });

    test('onStateChanged stream emits on changes', () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(),
      );

      final states = <_TestState>[];
      channel.onStateChanged.listen(states.add);

      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'count': 1, 'label': 'first'},
        },
      });

      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'count': 2, 'label': 'second'},
        },
      });

      expect(states, hasLength(2));
      expect(states[0].count, 1);
      expect(states[1].count, 2);

      channel.dispose();
    });

    test('default constructor works for main app side', () {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(),
      );

      expect(channel.state.count, 0);
      channel.dispose();
    });

    test('.overlay() constructor works for overlay side', () {
      // Need to dispose previous handler first since both use same prefix.
      final channel = FloatyStateChannel<_TestState>.overlay(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(count: 99, label: 'overlay'),
      );

      expect(channel.state.count, 99);
      expect(channel.state.label, 'overlay');
      channel.dispose();
    });

    test('dispose unregisters the handler', () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(),
      )..dispose();

      // After dispose, state messages should go to rawMessages.
      final rawReceived = <Object?>[];
      FloatyChannel.rawMessages.listen(rawReceived.add);

      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': {'count': 99, 'label': 'after-dispose'},
        },
      });

      // The handler is gone, so the message falls through to raw.
      expect(rawReceived, hasLength(1));
      // State should not have been updated.
      expect(channel.state.count, 0);
    });

    test('receiving message with non-map data is silently ignored', () async {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(count: 7, label: 'stable'),
      );

      final states = <_TestState>[];
      channel.onStateChanged.listen(states.add);

      // Send a message where 'data' is not a Map.
      await _simulateMessage({
        '_floaty_state': {
          'full': true,
          'data': 'not-a-map',
        },
      });

      expect(states, isEmpty);
      expect(channel.state.count, 7); // unchanged

      channel.dispose();
    });

    test('onStateChanged stream is broadcast', () {
      final channel = FloatyStateChannel<_TestState>(
        toJson: (s) => s.toJson(),
        fromJson: _TestState.fromJson,
        initialState: _TestState(),
      );

      final stream = channel.onStateChanged
        ..listen((_) {})
        ..listen((_) {}); // second listener should not throw
      expect(stream.isBroadcast, isTrue);

      channel.dispose();
    });
  });
}
