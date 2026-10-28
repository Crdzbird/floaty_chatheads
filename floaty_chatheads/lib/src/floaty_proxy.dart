/// Request and response proxy between the overlay and the main app.
///
/// The overlay calls services on the main app through
/// `FloatyProxyClient`; the main app provides them with
/// `FloatyProxyHost`. Failures surface as `FloatyProxyException`
/// subclasses.
library;

export 'package:floaty_chatheads/src/proxy/floaty_proxy_client.dart';
export 'package:floaty_chatheads/src/proxy/floaty_proxy_disconnected_exception.dart';
export 'package:floaty_chatheads/src/proxy/floaty_proxy_error_exception.dart';
export 'package:floaty_chatheads/src/proxy/floaty_proxy_exception.dart';
export 'package:floaty_chatheads/src/proxy/floaty_proxy_host.dart';
export 'package:floaty_chatheads/src/proxy/floaty_proxy_timeout_exception.dart';
