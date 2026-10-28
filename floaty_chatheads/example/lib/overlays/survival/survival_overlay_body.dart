part of '../survival_overlay.dart';

final class _SurvivalOverlayBody extends StatefulWidget {
  const _SurvivalOverlayBody({
    required this.kit,
    required this.state,
    required this.connected,
  });

  final FloatyOverlayKit<SurvivalState> kit;
  final SurvivalState state;
  final bool connected;

  @override
  State<_SurvivalOverlayBody> createState() => _SurvivalOverlayBodyState();
}
