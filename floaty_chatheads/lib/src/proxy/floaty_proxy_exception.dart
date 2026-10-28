/// Base exception for proxy call failures.
abstract class FloatyProxyException implements Exception {
  /// Base constructor for subclasses, carrying a failure [message].
  const FloatyProxyException(this.message);

  /// Description of the failure.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
