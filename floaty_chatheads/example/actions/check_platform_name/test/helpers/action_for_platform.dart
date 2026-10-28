import 'package:check_platform_name/check_platform_name.dart';

/// Builds a [CheckPlatformName] that reports [platform] as the host.
CheckPlatformName actionForPlatform(String platform) {
  return CheckPlatformName(
    isAndroid: () => platform == 'Android',
    isIOS: () => platform == 'iOS',
    isLinux: () => platform == 'Linux',
    isMacOS: () => platform == 'MacOS',
    isWindows: () => platform == 'Windows',
    isWeb: platform == 'Web',
  );
}
