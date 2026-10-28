import 'package:flutter/widgets.dart';

/// Signature for a builder that receives the current normalised animation
/// value (0.0 to 1.0) and returns a widget to render as the chathead icon.
typedef AnimatedIconBuilder = Widget Function(double animationValue);
