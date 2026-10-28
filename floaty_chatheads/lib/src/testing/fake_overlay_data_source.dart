import 'dart:async';

import 'package:floaty_chatheads/src/floaty_overlay.dart';

/// A fake data source for testing overlay-side logic without a running
/// platform. Simulates incoming data and lifecycle events, e.g.
/// `fake.emitData({'action': 'refresh'})` or `fake.emitTapped('default')`.
final class FakeOverlayDataSource {
  /// Creates a data source with open broadcast controllers.
  factory FakeOverlayDataSource() = FakeOverlayDataSource._;

  FakeOverlayDataSource._();

  /// Stream controller for simulating incoming data.
  final StreamController<Object?> dataController = StreamController.broadcast();

  /// Stream controller for simulating tap events.
  final StreamController<String> tapController = StreamController.broadcast();

  /// Stream controller for simulating close events.
  final StreamController<String> closeController = StreamController.broadcast();

  /// Stream controller for simulating expand events.
  final StreamController<String> expandController =
      StreamController.broadcast();

  /// Stream controller for simulating collapse events.
  final StreamController<String> collapseController =
      StreamController.broadcast();

  /// Stream controller for simulating drag-start events.
  final StreamController<ChatHeadDragEvent> dragStartController =
      StreamController.broadcast();

  /// Stream controller for simulating drag-end events.
  final StreamController<ChatHeadDragEvent> dragEndController =
      StreamController.broadcast();

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
  Future<void> dispose() async {
    await Future.wait([
      dataController.close(),
      tapController.close(),
      closeController.close(),
      expandController.close(),
      collapseController.close(),
      dragStartController.close(),
      dragEndController.close(),
    ]);
  }
}
