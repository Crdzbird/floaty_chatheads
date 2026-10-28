import 'package:flutter/material.dart';

/// Bold heading above a group of controls in the features showcase.
final class FeaturesSectionLabel extends StatelessWidget {
  /// Creates a heading showing [text].
  const factory FeaturesSectionLabel({required String text, Key? key}) =
      FeaturesSectionLabel._;

  const FeaturesSectionLabel._({required this.text, super.key});

  /// The heading text.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}
