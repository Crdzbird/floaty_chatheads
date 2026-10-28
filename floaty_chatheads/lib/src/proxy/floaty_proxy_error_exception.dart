import 'package:floaty_chatheads/src/proxy/floaty_proxy_exception.dart';

/// Thrown when the host-side handler threw an exception.
final class FloatyProxyErrorException extends FloatyProxyException {
  /// Creates the exception with the host's error [message].
  const factory FloatyProxyErrorException(String message) =
      FloatyProxyErrorException._;

  const FloatyProxyErrorException._(super.message);
}
