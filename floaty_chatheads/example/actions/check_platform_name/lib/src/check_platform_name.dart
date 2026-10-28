import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:fluttium/fluttium.dart';

/// {@template check_platform_name}
/// An action that checks the expected platform name.
///
/// Usage:
///
/// ```yaml
/// - checkPlatformName:
/// ```
/// {@endtemplate}
final class CheckPlatformName extends Action {
  /// {@macro check_platform_name}
  const factory CheckPlatformName({
    @visibleForTesting bool Function() isAndroid,
    @visibleForTesting bool Function() isIOS,
    @visibleForTesting bool Function() isLinux,
    @visibleForTesting bool Function() isMacOS,
    @visibleForTesting bool Function() isWindows,
    @visibleForTesting bool isWeb,
  }) = CheckPlatformName._;

  const CheckPlatformName._({
    this._isAndroid = _platformIsAndroid,
    this._isIOS = _platformIsIOS,
    this._isLinux = _platformIsLinux,
    this._isMacOS = _platformIsMacOS,
    this._isWindows = _platformIsWindows,
    this._isWeb = kIsWeb,
  });

  final bool _isWeb;

  final bool Function() _isAndroid;

  final bool Function() _isIOS;

  final bool Function() _isLinux;

  final bool Function() _isMacOS;

  final bool Function() _isWindows;

  String get _expectedPlatformName {
    if (_isWeb) return 'Web';
    if (_isAndroid()) return 'Android';
    if (_isIOS()) return 'iOS';
    if (_isLinux()) return 'Linux';
    if (_isMacOS()) return 'MacOS';
    if (_isWindows()) return 'Windows';
    throw UnsupportedError('Unsupported platform ${Platform.operatingSystem}');
  }

  @override
  Future<bool> execute(Tester tester) {
    return ExpectVisible(
      text: 'Platform Name: $_expectedPlatformName',
    ).execute(tester);
  }

  @override
  String description() => 'Check platform name: "$_expectedPlatformName"';
}

bool _platformIsAndroid() => Platform.isAndroid;
bool _platformIsIOS() => Platform.isIOS;
bool _platformIsLinux() => Platform.isLinux;
bool _platformIsMacOS() => Platform.isMacOS;
bool _platformIsWindows() => Platform.isWindows;
