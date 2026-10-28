import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Signature of `FloatyChatheads.addChatHead`.
typedef AddChatHeadFunction =
    Future<void> Function({
      required String id,
      IconSource? iconSource,
      Widget? iconWidget,
      double iconSize,
      double iconPixelRatio,
    });
