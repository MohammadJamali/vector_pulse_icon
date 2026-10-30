import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';

part 'draw_fill_animation.dart';
part 'glow_animation.dart';
part 'pulse_animation.dart';

/// An animation [VectorPulseIcon] can play, configured by its subclass. See
/// [IconAnimations] for ready-made ones.
///
/// Animations address the icon's parts by index; see [SvgParser] for how an
/// SVG is split into parts.
sealed class IconAnimation {
  const IconAnimation();
}
