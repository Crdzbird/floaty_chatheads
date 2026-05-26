/// Floaty Chatheads — a Flutter federated plugin for floating chathead
/// bubbles on Android and iOS.
///
/// {@macro floaty_chatheads}
///
/// ## Where to start
///
/// Most apps need only this barrel. Pick the right entry point for your
/// situation:
///
/// - **Show a chathead from your app:** [FloatyChatheads], or use
///   [FloatyLauncher] / [FloatyPermissionGate] for a one-call setup with
///   permission handling.
/// - **Build the overlay UI:** wrap your overlay in [FloatyOverlayApp] or
///   [FloatyOverlayScope]; use [FloatyOverlayBuilder] for reactive
///   rebuilds without touching streams.
/// - **Bidirectional messaging:** [FloatyHostKit] (main app side) and
///   [FloatyOverlayKit] (overlay side) bundle action routing, state
///   sync, and RPC into a single disposable.
/// - **High-frequency one-way data:** [FloatyProxyStream] with
///   [StreamKey].
/// - **Pre-built overlay widgets:** [FloatyMiniPlayer],
///   [FloatyNotificationCard].
///
/// ## Advanced usage
///
/// If you need direct access to the underlying messaging primitives
/// (`FloatyActionRouter`, `FloatyStateChannel`, `FloatyProxyHost`,
/// `FloatyProxyClient`) instead of using the Kits, import:
///
/// ```dart
/// import 'package:floaty_chatheads/advanced.dart';
/// ```
///
/// ## Testing
///
/// `import 'package:floaty_chatheads/testing.dart';` for a
/// `FakeFloatyPlatform` and other test utilities.
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

export 'src/animated_widget_icon.dart';
export 'src/floaty_action_router.dart' show ActionKey, FloatyAction, QueueOverflowStrategy;
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
export 'src/floaty_proxy_stream.dart' show FloatyProxyStream, StreamKey;
export 'src/floaty_scope.dart';
export 'src/widget_to_icon_source.dart';
export 'src/widgets/floaty_mini_player.dart';
export 'src/widgets/floaty_notification_card.dart';
