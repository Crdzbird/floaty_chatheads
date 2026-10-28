part of 'floaty_chatheads_platform.dart';

/// Bubble and panel controls of [FloatyChatheadsPlatform].
mixin _FloatyChatheadsControls {
  /// {@template floaty_chatheads_platform.add_chat_head}
  /// Adds a new chathead bubble to the existing group.
  /// {@endtemplate}
  Future<void> addChatHead(AddChatHeadConfig config) =>
      FloatyChatheadsPlatform._unimplemented('addChatHead');

  /// {@template floaty_chatheads_platform.remove_chat_head}
  /// Removes a chathead bubble by its [id].
  ///
  /// If the removed bubble was the last one, the overlay service stops.
  /// {@endtemplate}
  Future<void> removeChatHead(String id) =>
      FloatyChatheadsPlatform._unimplemented('removeChatHead');

  /// {@template floaty_chatheads_platform.resize_content}
  /// Resizes the overlay content panel to [width] x [height] logical pixels.
  /// {@endtemplate}
  Future<void> resizeContent(int width, int height) =>
      FloatyChatheadsPlatform._unimplemented('resizeContent');

  /// {@template floaty_chatheads_platform.update_flag}
  /// Updates the window behavior flag.
  ///
  /// See [OverlayFlag] for available values.
  /// {@endtemplate}
  Future<void> updateFlag(OverlayFlag flag) =>
      FloatyChatheadsPlatform._unimplemented('updateFlag');

  /// {@template floaty_chatheads_platform.get_overlay_position}
  /// Gets the current overlay position as an [OverlayPosition].
  /// {@endtemplate}
  Future<OverlayPosition> getOverlayPosition() =>
      FloatyChatheadsPlatform._unimplemented('getOverlayPosition');

  /// {@template floaty_chatheads_platform.update_badge}
  /// Updates the badge count on the chathead bubble.
  ///
  /// Pass `0` to hide the badge.
  /// {@endtemplate}
  Future<void> updateBadge(int count) =>
      FloatyChatheadsPlatform._unimplemented('updateBadge');

  /// {@template floaty_chatheads_platform.expand_chat_head}
  /// Programmatically expands the chathead to show its content panel.
  ///
  /// Has no effect if the chathead is already expanded.
  /// {@endtemplate}
  Future<void> expandChatHead() =>
      FloatyChatheadsPlatform._unimplemented('expandChatHead');

  /// {@template floaty_chatheads_platform.collapse_chat_head}
  /// Programmatically collapses the chathead content panel.
  ///
  /// Has no effect if the chathead is already collapsed.
  /// {@endtemplate}
  Future<void> collapseChatHead() =>
      FloatyChatheadsPlatform._unimplemented('collapseChatHead');

  /// {@template floaty_chatheads_platform.update_chat_head_icon}
  /// Replaces the chathead icon with raw RGBA pixel data.
  ///
  /// [id] identifies which bubble to update. [rgbaBytes] contains the
  /// pixel data in RGBA order, with dimensions [width] x [height].
  ///
  /// On Android the bitmap is created off the main thread; on iOS the
  /// chathead is already a Flutter view so this is a no-op.
  /// {@endtemplate}
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) => FloatyChatheadsPlatform._unimplemented('updateChatHeadIcon');
}
