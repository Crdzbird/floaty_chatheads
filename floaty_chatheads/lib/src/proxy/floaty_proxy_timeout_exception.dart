import 'package:floaty_chatheads/src/proxy/floaty_proxy_exception.dart';

/// Thrown when a proxy call exceeds its timeout.
final class FloatyProxyTimeoutException extends FloatyProxyException {
  /// Creates the exception for a call to [service].[method].
  const factory FloatyProxyTimeoutException(String service, String method) =
      FloatyProxyTimeoutException._;

  const FloatyProxyTimeoutException._(String service, String method)
    : super('Proxy call to $service.$method timed out');
}
