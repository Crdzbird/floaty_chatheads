/// Advanced floaty_chatheads APIs for power users who need direct access
/// to the underlying messaging primitives.
///
/// Most apps should import `package:floaty_chatheads/floaty_chatheads.dart`
/// and use `FloatyHostKit` / `FloatyOverlayKit`, which bundle these
/// primitives behind one disposable. Import this barrel only when you
/// need to wire individual components yourself (e.g. exposing a router
/// without state syncing, or running multiple isolated state channels).
///
/// Exports:
///
/// - `FloatyActionRouter` — typed action dispatch
/// - `FloatyStateChannel` — bidirectional state sync
/// - `FloatyProxyHost` / `FloatyProxyClient` — RPC with response
///
/// `FloatyProxyStream`, `FloatyMessenger`, `FloatyConnectionState`,
/// `FloatyAction`, `ActionKey`, and `StreamKey` stay in the main barrel
/// because they are commonly needed even when using the Kits.
library;

export 'src/floaty_action_router.dart' show FloatyActionRouter;
export 'src/floaty_proxy.dart'
    show
        FloatyProxyClient,
        FloatyProxyDisconnectedException,
        FloatyProxyErrorException,
        FloatyProxyException,
        FloatyProxyHost,
        FloatyProxyTimeoutException;
export 'src/floaty_state_channel.dart' show FloatyStateChannel;
