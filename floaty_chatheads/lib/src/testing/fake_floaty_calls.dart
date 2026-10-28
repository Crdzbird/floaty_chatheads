import 'dart:typed_data';

import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Call tracking and return-value switches of `FakeFloatyPlatform`.
mixin FakeFloatyCalls {
  /// Whether `checkPermission` was called.
  bool checkPermissionCalled = false;

  /// Whether `requestPermission` was called.
  bool requestPermissionCalled = false;

  /// Whether `showChatHead` was called.
  bool showChatHeadCalled = false;

  /// Whether `closeChatHead` was called.
  bool closeChatHeadCalled = false;

  /// The last [ChatHeadConfig] passed to `showChatHead`.
  ChatHeadConfig? lastConfig;

  /// The last [AddChatHeadConfig] passed to `addChatHead`.
  AddChatHeadConfig? lastAddConfig;

  /// The last ID passed to `removeChatHead`.
  String? lastRemovedId;

  /// The last badge count passed to `updateBadge`.
  int? lastBadgeCount;

  /// Controls the return value of `checkPermission`.
  bool permissionGranted = true;

  /// Controls the return value of `isActive`.
  bool active = false;

  /// The last RGBA bytes passed to `updateChatHeadIcon`.
  Uint8List? lastIconBytes;

  /// The last chathead ID passed to `updateChatHeadIcon`.
  String? lastIconId;

  /// Resets all call tracking state.
  void reset() {
    checkPermissionCalled = false;
    requestPermissionCalled = false;
    showChatHeadCalled = false;
    closeChatHeadCalled = false;
    lastConfig = null;
    lastAddConfig = null;
    lastRemovedId = null;
    lastBadgeCount = null;
  }
}
