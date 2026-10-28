import 'dart:typed_data';

import 'package:floaty_chatheads/src/testing/fake_floaty_calls.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// A fake [FloatyChatheadsPlatform] for unit tests that records every call
/// and lets you control return values:
///
/// ```dart
/// final fake = FakeFloatyPlatform();
/// FloatyChatheadsPlatform.instance = fake;
/// await FloatyChatheads.showChatHead(entryPoint: 'test');
/// expect(fake.lastConfig?.entryPoint, 'test');
/// ```
///
/// Subclass it to override individual calls, for example to throw.
class FakeFloatyPlatform extends FloatyChatheadsPlatform with FakeFloatyCalls {
  /// Creates a fake with permission granted and no active chathead.
  FakeFloatyPlatform();

  @override
  Future<bool> checkPermission() async {
    checkPermissionCalled = true;
    return permissionGranted;
  }

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalled = true;
    return permissionGranted;
  }

  @override
  Future<void> showChatHead(ChatHeadConfig config) async {
    showChatHeadCalled = true;
    lastConfig = config;
    active = true;
  }

  @override
  Future<void> closeChatHead() async {
    closeChatHeadCalled = true;
    active = false;
  }

  @override
  Future<bool> isActive() async => active;

  @override
  Future<void> addChatHead(AddChatHeadConfig config) async {
    lastAddConfig = config;
  }

  @override
  Future<void> removeChatHead(String id) async {
    lastRemovedId = id;
  }

  @override
  Future<void> updateBadge(int count) async {
    lastBadgeCount = count;
  }

  @override
  Future<void> expandChatHead() async {}

  @override
  Future<void> collapseChatHead() async {}

  @override
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) async {
    lastIconId = id;
    lastIconBytes = rgbaBytes;
  }
}
