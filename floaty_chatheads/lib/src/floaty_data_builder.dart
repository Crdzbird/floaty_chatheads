import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';

part 'builders/floaty_data_builder_state.dart';

/// Reactive builder that subscribes to [FloatyChatheads.onData] and
/// rebuilds whenever new data arrives from the overlay.
///
/// [onData] is a reducer: it receives the current state and the raw
/// incoming data and returns the new state, which covers both value
/// replacement and list accumulation:
///
/// ```dart
/// FloatyDataBuilder<int>(
///   initialData: 0,
///   onData: (count, raw) => raw is Map ? raw['count'] as int : count,
///   builder: (context, count) => Text('$count'),
/// )
/// ```
///
/// The subscription follows the widget's lifecycle. The shared channel is
/// not disposed.
final class FloatyDataBuilder<T> extends StatefulWidget {
  /// Creates a builder starting from [initialData].
  const factory FloatyDataBuilder({
    required T initialData,
    required T Function(T current, Object? raw) onData,
    required Widget Function(BuildContext context, T data) builder,
    Key? key,
  }) = FloatyDataBuilder<T>._;

  const FloatyDataBuilder._({
    required this.initialData,
    required this.onData,
    required this.builder,
    super.key,
  });

  /// The state value used before any data arrives from the overlay.
  final T initialData;

  /// Reducer called whenever [FloatyChatheads.onData] emits. Return the
  /// current value unchanged to ignore the message.
  final T Function(T current, Object? raw) onData;

  /// Builder that receives the current reduced state.
  final Widget Function(BuildContext context, T data) builder;

  @override
  State<FloatyDataBuilder<T>> createState() => _FloatyDataBuilderState<T>();
}
