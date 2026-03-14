/// Floaty Chatheads -- a Flutter federated plugin for floating chathead
/// bubbles on Android and iOS.
///
/// {@macro floaty_chatheads}
///
/// For the overlay-side API, see `FloatyOverlay`.
library;

export 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart'
    show
        AddChatHeadConfig,
        ChatHeadConfig,
        ChatHeadTheme,
        ContentSizePreset,
        EntranceAnimation,
        NotificationVisibility,
        OverlayFlag,
        OverlayPosition,
        SnapEdge;

export 'src/floaty_chatheads.dart';
export 'src/floaty_overlay.dart';
export 'src/floaty_permission_gate.dart';
export 'src/generated/floaty_chatheads_overlay_api.g.dart'
    show OverlayFlagMessage, OverlayPositionMessage;
