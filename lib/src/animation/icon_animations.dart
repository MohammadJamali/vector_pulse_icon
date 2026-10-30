import 'package:flutter/animation.dart';

import 'icon_animation.dart';

/// Ready-made animations for [VectorPulseIcon].
abstract final class IconAnimations {
  static const loadingPulse = PulseAnimation(
    partIndices: [0, 1],
    order: PulseOrder.sequence,
    sequence: [0, 1],
    seed: 1,
    interval: Duration(milliseconds: 300),
    fadeOutDuration: Duration(milliseconds: 300),
    holdDuration: Duration(milliseconds: 300),
    fadeInDuration: Duration(milliseconds: 300),
    dimOpacity: 0.3,
  );

  static const fillEmptyPulse = PulseAnimation(
    partIndices: [0, 1],
    order: PulseOrder.sequence,
    sequence: [0, 1],
    seed: 1,
    interval: Duration(milliseconds: 100),
    fadeOutDuration: Duration(milliseconds: 200),
    holdDuration: Duration.zero,
    fadeInDuration: Duration(milliseconds: 1500),
    restOpacity: 0.3,
    dimOpacity: 1,
  );

  static const emptyFillPulse = PulseAnimation(
    partIndices: [0, 1],
    order: PulseOrder.sequence,
    sequence: [0, 1],
    seed: 1,
    interval: Duration(milliseconds: 100),
    fadeOutDuration: Duration(milliseconds: 200),
    holdDuration: Duration.zero,
    fadeInDuration: Duration(milliseconds: 1500),
    dimOpacity: 0.3,
  );

  static const pulseGlow = GlowAnimation(
    partIndices: [0, 1],
    keyframes: [
      GlowKeyframe(duration: Duration.zero, opacity: 0.2, scale: 1, sigma: 64),
      GlowKeyframe(
        duration: Duration(milliseconds: 100),
        opacity: 0.8,
        scale: 1.05,
        sigma: 64,
        curve: Curves.easeOut,
      ),
      GlowKeyframe(
        duration: Duration(milliseconds: 500),
        opacity: 0.2,
        scale: 1,
        sigma: 64,
        curve: Curves.easeInOut,
      ),
    ],
  );

  static const musicLightDance = GlowAnimation(
    partIndices: [0, 1],
    keyframes: [
      GlowKeyframe(
        duration: Duration(milliseconds: 120),
        opacity: 0.3,
        scale: 1.1,
        sigma: 64,
      ),
      GlowKeyframe(
        duration: Duration(milliseconds: 180),
        opacity: 0.6,
        scale: 1.15,
        sigma: 64,
        curve: Curves.easeOut,
      ),
      GlowKeyframe(
        duration: Duration(milliseconds: 240),
        opacity: 0.3,
        scale: 1.1,
        sigma: 64,
        curve: Curves.easeInOut,
      ),
      GlowKeyframe(
        duration: Duration(milliseconds: 180),
        opacity: 0.5,
        scale: 1.2,
        sigma: 64,
        curve: Curves.easeOut,
      ),
      GlowKeyframe(
        duration: Duration(milliseconds: 240),
        opacity: 0.3,
        scale: 1.1,
        sigma: 64,
        curve: Curves.easeInOutCubic,
      ),
      GlowKeyframe(
        duration: Duration(milliseconds: 180),
        opacity: 0.7,
        scale: 1.1,
        sigma: 64,
        curve: Curves.easeInOut,
      ),
    ],
  );

  static const drawAndFill = DrawFillAnimation(
    strokeWidth: 2,
    draw: DrawFillPhase(
      duration: Duration(milliseconds: 1000),
      delays: [
        Duration.zero,
        Duration(milliseconds: 100),
        Duration(milliseconds: 200),
        Duration(milliseconds: 300),
        Duration(milliseconds: 400),
        Duration(milliseconds: 500),
      ],
    ),
    fill: DrawFillPhase(
      duration: Duration(milliseconds: 1000),
      delays: [
        Duration(milliseconds: 800),
        Duration(milliseconds: 900),
        Duration(milliseconds: 1000),
        Duration(milliseconds: 1100),
        Duration(milliseconds: 1200),
        Duration(milliseconds: 1300),
      ],
    ),
  );

  static const values = <IconAnimation>[
    loadingPulse,
    fillEmptyPulse,
    emptyFillPulse,
    pulseGlow,
    musicLightDance,
    drawAndFill,
  ];
}
