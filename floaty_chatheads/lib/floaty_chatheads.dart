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
/// - `FloatyController` -- lifecycle-aware controller for declarative usage
/// - `FloatyMessenger` -- type-safe messaging wrapper
/// - `FloatyStateChannel` -- auto-syncing typed state between app and overlay
/// - `FloatyActionRouter` -- typed bidirectional action routing
/// - `FloatyProxyHost` / `FloatyProxyClient` -- overlay-side plugin access
/// - `FloatyHostKit` / `FloatyOverlayKit` -- all-in-one communication bundles
/// - `FloatyOverlayScope` -- zero-boilerplate reactive scope for overlays
/// - `FloatyDataBuilder` -- reactive builder for main-app data reception
/// - `FloatyOverlayBuilder` -- zero-boilerplate builder for overlay widgets
///
/// For pre-built overlay widgets, see:
/// - `FloatyMiniPlayer` -- media player overlay
/// - `FloatyNotificationCard` -- toast/notification overlay
///
/// For testing, import `package:floaty_chatheads/testing.dart` instead.
library;

export 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart'
    show
        AddChatHeadConfig,
        AssetIconSource,
        BytesIconSource,
        ChatHeadAssets,
        ChatHeadConfig,
        ChatHeadTheme,
        ContentSizePreset,
        EntranceAnimation,
        IconSource,
        NetworkIconSource,
        NotificationConfig,
        NotificationVisibility,
        OverlayFlag,
        OverlayPosition,
        SnapConfig,
        SnapEdge;

export 'src/floaty_action_router.dart';
export 'src/floaty_chatheads.dart';
export 'src/floaty_connection_state.dart';
export 'src/floaty_controller.dart';
export 'src/floaty_data_builder.dart';
export 'src/floaty_kit.dart';
export 'src/floaty_launcher.dart';
export 'src/floaty_messenger.dart';
export 'src/floaty_overlay.dart';
export 'src/floaty_overlay_app.dart';
export 'src/floaty_overlay_builder.dart';
export 'src/floaty_overlay_scope.dart';
export 'src/floaty_permission_gate.dart';
export 'src/floaty_proxy.dart';
export 'src/floaty_scope.dart';
export 'src/floaty_state_channel.dart';
export 'src/generated/floaty_chatheads_overlay_api.g.dart'
    show OverlayFlagMessage, OverlayPositionMessage;
export 'src/widgets/floaty_mini_player.dart';
export 'src/widgets/floaty_notification_card.dart';
