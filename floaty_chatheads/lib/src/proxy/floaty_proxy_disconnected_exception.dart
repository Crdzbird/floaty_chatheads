import 'package:floaty_chatheads/src/proxy/floaty_proxy_exception.dart';

/// Thrown when a proxy call is attempted while the main app is
/// disconnected.
///
/// This avoids a full timeout wait when the main app is known to be
/// unavailable. Pass a `fallback` to `FloatyProxyClient.call` to get a
/// default value instead.
final class FloatyProxyDisconnectedException extends FloatyProxyException {
  /// Creates the exception for a call to [service].[method].
  const factory FloatyProxyDisconnectedException(
    String service,
    String method,
  ) = FloatyProxyDisconnectedException._;

  const FloatyProxyDisconnectedException._(String service, String method)
    : super('Main app is disconnected, cannot call $service.$method');
}
