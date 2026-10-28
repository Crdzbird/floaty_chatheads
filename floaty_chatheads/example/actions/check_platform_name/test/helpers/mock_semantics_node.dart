import 'package:flutter/semantics.dart';
import 'package:mocktail/mocktail.dart';

/// A mocktail double for [SemanticsNode] with a printable `toString`.
final class MockSemanticsNode extends Mock implements SemanticsNode {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}
