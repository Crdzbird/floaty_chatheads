import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:floaty_chatheads_platform_interface/src/method_channel_arguments.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// Fallback [FloatyChatheadsPlatform] implementation using method channels.
///
/// Platform packages (Android/iOS) override this with their own
/// Pigeon-based implementations at registration time.
final class MethodChannelFloatyChatheads extends FloatyChatheadsPlatform {
  /// Creates the method channel fallback implementation.
  factory MethodChannelFloatyChatheads() = MethodChannelFloatyChatheads._;

  MethodChannelFloatyChatheads._();

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('floaty_chatheads');

  Future<void> _call(String method, [Object? arguments]) =>
      methodChannel.invokeMethod<void>(method, arguments);

  Future<bool> _ask(String method) async =>
      await methodChannel.invokeMethod<bool>(method) ?? false;

  /// {@macro floaty_chatheads_platform.check_permission}
  @override
  Future<bool> checkPermission() => _ask('checkPermission');

  /// {@macro floaty_chatheads_platform.request_permission}
  @override
  Future<bool> requestPermission() => _ask('requestPermission');

  /// {@macro floaty_chatheads_platform.show_chat_head}
  @override
  Future<void> showChatHead(ChatHeadConfig config) =>
      _call('showChatHead', MethodChannelArguments.showChatHead(config));

  /// {@macro floaty_chatheads_platform.close_chat_head}
  @override
  Future<void> closeChatHead() => _call('closeChatHead');

  /// {@macro floaty_chatheads_platform.is_active}
  @override
  Future<bool> isActive() => _ask('isActive');

  /// {@macro floaty_chatheads_platform.add_chat_head}
  @override
  Future<void> addChatHead(AddChatHeadConfig config) =>
      _call('addChatHead', MethodChannelArguments.addChatHead(config));

  /// {@macro floaty_chatheads_platform.remove_chat_head}
  @override
  Future<void> removeChatHead(String id) => _call('removeChatHead', {'id': id});

  /// {@macro floaty_chatheads_platform.resize_content}
  @override
  Future<void> resizeContent(int width, int height) =>
      _call('resizeContent', {'width': width, 'height': height});

  /// {@macro floaty_chatheads_platform.update_flag}
  @override
  Future<void> updateFlag(OverlayFlag flag) =>
      _call('updateFlag', {'flag': flag.index});

  /// {@macro floaty_chatheads_platform.close_overlay}
  @override
  Future<void> closeOverlay() => _call('closeOverlay');

  /// {@macro floaty_chatheads_platform.get_overlay_position}
  @override
  Future<OverlayPosition> getOverlayPosition() async =>
      MethodChannelArguments.overlayPosition(
        await methodChannel.invokeMapMethod('getOverlayPosition'),
      );

  /// {@macro floaty_chatheads_platform.update_badge}
  @override
  Future<void> updateBadge(int count) => _call('updateBadge', {'count': count});

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  @override
  Future<void> expandChatHead() => _call('expandChatHead');

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  @override
  Future<void> collapseChatHead() => _call('collapseChatHead');

  /// {@macro floaty_chatheads_platform.update_chat_head_icon}
  @override
  Future<void> updateChatHeadIcon(
    String id,
    Uint8List rgbaBytes,
    int width,
    int height,
  ) => _call(
    'updateChatHeadIcon',
    MethodChannelArguments.chatHeadIcon(id, rgbaBytes, width, height),
  );
}
