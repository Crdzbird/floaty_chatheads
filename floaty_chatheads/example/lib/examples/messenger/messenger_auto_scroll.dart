import 'package:flutter/widgets.dart';

/// Scrolls a chat list to its newest message.
extension MessengerAutoScroll on ScrollController {
  /// Animates to the bottom of the list after the next frame is laid out.
  void scrollToBottomAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasClients) return;
      await animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }
}
