import 'package:floaty_chatheads/src/floaty_kit.dart';
import 'package:flutter/widgets.dart';

/// Signature of `FloatyOverlayScope.builder`: receives the kit, the
/// current state and the connection status ([C] is `bool`).
typedef FloatyOverlayScopeBuilder<S, C> =
    Widget Function(
      BuildContext context,
      FloatyOverlayKit<S> kit,
      S state,
      C connected,
    );
