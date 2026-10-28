import 'package:flutter/material.dart';

/// Title row above a log with an entry count and a clear button.
final class DashboardLogHeader extends StatelessWidget {
  /// Creates a header reading "[label] ([count])".
  const factory DashboardLogHeader({
    required String label,
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = DashboardLogHeader._;

  const DashboardLogHeader._({
    required this.label,
    required this.count,
    required this.onClear,
    super.key,
  });

  /// Title of the log.
  final String label;

  /// Number of entries in the log.
  final int count;

  /// Called when "Clear" is pressed.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$label ($count)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          if (count > 0)
            TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}
