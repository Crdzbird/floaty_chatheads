import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/floaty_chatheads_api.g.dart',
    dartPackageName: 'floaty_chatheads',
    swiftOut:
        'ios/floaty_chatheads_ios/Sources/floaty_chatheads_ios/FloatyChatheadsApi.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
enum OverlayFlagMessage {
  defaultFlag,
  clickThrough,
  focusPointer,
}

enum NotificationVisibilityMessage {
  visibilityPublic,
  visibilitySecret,
  visibilityPrivate,
}

class ChatHeadConfig {
  ChatHeadConfig({
    required this.entryPoint,
    this.contentWidth,
    this.contentHeight,
    this.chatheadIconAsset,
    this.closeIconAsset,
    this.closeBackgroundAsset,
    this.notificationTitle,
    this.notificationIconAsset,
    required this.flag,
    required this.enableDrag,
    required this.notificationVisibility,
  });

  final String entryPoint;
  final int? contentWidth;
  final int? contentHeight;
  final String? chatheadIconAsset;
  final String? closeIconAsset;
  final String? closeBackgroundAsset;
  final String? notificationTitle;
  final String? notificationIconAsset;
  final OverlayFlagMessage flag;
  final bool enableDrag;
  final NotificationVisibilityMessage notificationVisibility;
}

class OverlayPositionMessage {
  OverlayPositionMessage({required this.x, required this.y});

  final double x;
  final double y;
}

class AddChatHeadConfig {
  AddChatHeadConfig({required this.id, this.iconAsset});

  final String id;
  final String? iconAsset;
}

@HostApi()
abstract class FloatyHostApi {
  bool checkPermission();

  @async
  bool requestPermission();

  void showChatHead(ChatHeadConfig config);

  void closeChatHead();

  bool isChatHeadActive();

  void addChatHead(AddChatHeadConfig config);

  void removeChatHead(String id);
}

@HostApi()
abstract class FloatyOverlayHostApi {
  void resizeContent(int width, int height);

  void updateFlag(OverlayFlagMessage flag);

  void closeOverlay();

  OverlayPositionMessage getOverlayPosition();
}

@FlutterApi()
abstract class FloatyOverlayFlutterApi {
  void onChatHeadTapped(String id);

  void onChatHeadClosed(String id);
}
