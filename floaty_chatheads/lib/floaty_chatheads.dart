/// Floaty Chatheads -- a Flutter federated plugin for floating chathead
/// bubbles on Android and iOS.
///
/// {@macro floaty_chatheads}
///
/// For the overlay-side API, see `FloatyOverlay`.
///
/// For convenience helpers that reduce boilerplate, see:
/// - `FloatyOverlayApp` -- one-liner to bootstrap an overlay entry point
/// - `FloatyScope` -- InheritedWidget that auto-wires all overlay streams
/// - `FloatyLauncher` -- one-call launcher with automatic permission handling
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
export 'src/floaty_launcher.dart';
export 'src/floaty_overlay.dart';
export 'src/floaty_overlay_app.dart';
export 'src/floaty_permission_gate.dart';
export 'src/floaty_scope.dart';
export 'src/generated/floaty_chatheads_overlay_api.g.dart'
    show OverlayFlagMessage, OverlayPositionMessage;
