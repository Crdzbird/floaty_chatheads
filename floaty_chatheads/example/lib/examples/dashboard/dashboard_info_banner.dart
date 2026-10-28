import 'package:flutter/material.dart';

/// Light blue banner with an info icon explaining how to start the demo.
final class DashboardInfoBanner extends StatelessWidget {
  /// Creates a banner showing [text].
  const factory DashboardInfoBanner({required String text, Key? key}) =
      DashboardInfoBanner._;

  const DashboardInfoBanner._({required this.text, super.key});

  /// The hint text.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
