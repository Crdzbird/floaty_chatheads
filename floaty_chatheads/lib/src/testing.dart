/// Testing utilities for floaty_chatheads.
///
/// Import this file in your test files to get access to mock/fake
/// implementations that let you unit-test overlay-dependent code
/// without a running platform:
///
/// ```dart
/// import 'package:floaty_chatheads/testing.dart';
/// ```
library;

import 'dart:async';

import 'package:floaty_chatheads/src/floaty_overlay.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template fake_floaty_platform}
/// A fake implementation of [FloatyChatheadsPlatform] for unit testing.
///
/// Tracks all method calls and allows you to control return values:
///
/// ```dart
/// final fake = FakeFloatyPlatform();
/// FloatyChatheadsPlatform.instance = fake;
///
/// // Now FloatyChatheads.showChatHead() calls fake.showChatHead().
/// await FloatyChatheads.showChatHead(entryPoint: 'test');
///
/// expect(fake.showChatHeadCalled, isTrue);
/// expect(fake.lastConfig?.entryPoint, equals('test'));
/// ```
/// {@endtemplate}
class FakeFloatyPlatform extends FloatyChatheadsPlatform {
  /// Whether [checkPermission] was called.
  bool checkPermissionCalled = false;

  /// Whether [requestPermission] was called.
  bool requestPermissionCalled = false;

  /// Whether [showChatHead] was called.
  bool showChatHeadCalled = false;

  /// Whether [closeChatHead] was called.
  bool closeChatHeadCalled = false;

  /// The last [ChatHeadConfig] passed to [showChatHead].
  ChatHeadConfig? lastConfig;

  /// The last [AddChatHeadConfig] passed to [addChatHead].
  AddChatHeadConfig? lastAddConfig;

  /// The last ID passed to [removeChatHead].
  String? lastRemovedId;

  /// The last badge count passed to [updateBadge].
  int? lastBadgeCount;

  /// Controls the return value of [checkPermission].
  bool permissionGranted = true;

  /// Controls the return value of [isActive].
  bool active = false;

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
}

/// {@template fake_overlay_data_source}
/// A fake data source for testing overlay-side logic without
/// a running platform.
///
/// Simulates incoming data and lifecycle events:
///
/// ```dart
/// final fake = FakeOverlayDataSource();
///
/// // Simulate main app sending data.
/// fake.emitData({'action': 'refresh'});
///
/// // Simulate chathead tap.
/// fake.emitTapped('default');
///
/// // Simulate palette delivery.
/// fake.emitPalette({'primary': 0xFF6200EE});
/// ```
/// {@endtemplate}
class FakeOverlayDataSource {
  /// Stream controller for simulating incoming data.
  final StreamController<Object?> dataController =
      StreamController<Object?>.broadcast();

  /// Stream controller for simulating tap events.
  final StreamController<String> tapController =
      StreamController<String>.broadcast();

  /// Stream controller for simulating close events.
  final StreamController<String> closeController =
      StreamController<String>.broadcast();

  /// Stream controller for simulating expand events.
  final StreamController<String> expandController =
      StreamController<String>.broadcast();

  /// Stream controller for simulating collapse events.
  final StreamController<String> collapseController =
      StreamController<String>.broadcast();

  /// Stream controller for simulating drag-start events.
  final StreamController<ChatHeadDragEvent> dragStartController =
      StreamController<ChatHeadDragEvent>.broadcast();

  /// Stream controller for simulating drag-end events.
  final StreamController<ChatHeadDragEvent> dragEndController =
      StreamController<ChatHeadDragEvent>.broadcast();

  /// The last data sent via [sendData].
  Object? lastSentData;

  /// All data sent via [sendData], in order.
  final List<Object?> sentData = [];

  /// Simulates the main app sending data to the overlay.
  void emitData(Object? data) => dataController.add(data);

  /// Simulates a chathead tap event.
  void emitTapped(String id) => tapController.add(id);

  /// Simulates a chathead close event.
  void emitClose(String id) => closeController.add(id);

  /// Simulates an expand event.
  void emitExpanded(String id) => expandController.add(id);

  /// Simulates a collapse event.
  void emitCollapsed(String id) => collapseController.add(id);

  /// Simulates a drag-start event.
  void emitDragStart(String id, double x, double y) =>
      dragStartController.add(ChatHeadDragEvent(id: id, x: x, y: y));

  /// Simulates a drag-end event.
  void emitDragEnd(String id, double x, double y) =>
      dragEndController.add(ChatHeadDragEvent(id: id, x: x, y: y));

  /// Records data that would be sent to the main app.
  void sendData(Object? data) {
    lastSentData = data;
    sentData.add(data);
  }

  /// Closes all controllers.
  void dispose() {
    unawaited(dataController.close());
    unawaited(tapController.close());
    unawaited(closeController.close());
    unawaited(expandController.close());
    unawaited(collapseController.close());
    unawaited(dragStartController.close());
    unawaited(dragEndController.close());
  }
}
