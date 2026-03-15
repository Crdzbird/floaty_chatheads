import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_data_builder}
/// Reactive builder that subscribes to [FloatyChatheads.onData] and rebuilds
/// whenever new data arrives from the overlay.
///
/// Uses a **reducer** pattern — [onData] receives the current state and the
/// raw incoming data, and returns the new state. This handles both simple
/// value replacement and list accumulation with a single API:
///
/// ```dart
/// // Simple value:
/// FloatyDataBuilder<int>(
///   initialData: 0,
///   onData: (count, raw) =>
///       raw is Map && raw['count'] is int ? raw['count'] as int : count,
///   builder: (context, count) => Text('$count'),
/// )
///
/// // Accumulating list:
/// FloatyDataBuilder<List<String>>(
///   initialData: const [],
///   onData: (msgs, raw) =>
///       raw is Map ? [...msgs, '${raw['text']}'] : msgs,
///   builder: (context, messages) => ListView(...),
/// )
/// ```
///
/// The widget manages the stream subscription lifecycle automatically —
/// subscribing on mount, guarding with `mounted`, and cancelling on dispose.
/// It does **not** call [FloatyChatheads.dispose] because the channel is a
/// shared singleton.
/// {@endtemplate}
final class FloatyDataBuilder<T> extends StatefulWidget {
  /// {@macro floaty_data_builder}
  const FloatyDataBuilder({
    required this.initialData,
    required this.onData,
    required this.builder,
    super.key,
  });

  /// The state value used before any data arrives from the overlay.
  final T initialData;

  /// Reducer called whenever [FloatyChatheads.onData] emits.
  ///
  /// Receives the current state and raw incoming data, and returns the
  /// new state. Return the current value unchanged to ignore the message.
  final T Function(T current, Object? raw) onData;

  /// Builder that receives the current reduced state.
  final Widget Function(BuildContext context, T data) builder;

  @override
  State<FloatyDataBuilder<T>> createState() => _FloatyDataBuilderState<T>();
}

class _FloatyDataBuilderState<T> extends State<FloatyDataBuilder<T>> {
  late T _data;
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _sub = FloatyChatheads.onData.listen((raw) {
      if (!mounted) return;
      setState(() => _data = widget.onData(_data, raw));
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _data);
}
