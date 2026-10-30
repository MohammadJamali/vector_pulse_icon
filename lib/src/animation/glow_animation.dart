part of 'icon_animation.dart';

/// Moves a blurred glow behind parts of the icon through [keyframes].
class GlowAnimation extends IconAnimation {
  const GlowAnimation({
    required this.keyframes,
    this.partIndices = const [],
    this.loop = true,
    this.color,
  });

  /// The glow's states in order; each keyframe is reached [GlowKeyframe.duration]
  /// after the previous one.
  final List<GlowKeyframe> keyframes;

  /// The parts that glow; empty means all of them.
  final List<int> partIndices;

  final bool loop;

  /// The glow colour; null uses each part's own colour.
  final Color? color;

  Duration get duration =>
      keyframes.fold(Duration.zero, (total, frame) => total + frame.duration);

  /// The glow [elapsed] into one run through [keyframes].
  GlowKeyframe frameAt(Duration elapsed) {
    if (keyframes.isEmpty) {
      return const GlowKeyframe(
        duration: Duration.zero,
        opacity: 0,
        scale: 1,
        sigma: 0,
      );
    }
    var start = Duration.zero;
    for (var i = 1; i < keyframes.length; i++) {
      final to = keyframes[i];
      final end = start + to.duration;
      if (elapsed <= end) {
        final t = to.curve.transform(_fraction(elapsed - start, to.duration));
        return GlowKeyframe.lerp(keyframes[i - 1], to, t);
      }
      start = end;
    }
    return keyframes.last;
  }
}

class GlowKeyframe {
  const GlowKeyframe({
    required this.duration,
    required this.opacity,
    required this.scale,
    required this.sigma,
    this.curve = Curves.linear,
  });

  /// The time to move here from the previous keyframe.
  final Duration duration;

  final double opacity;

  /// The glow's size relative to the part.
  final double scale;

  /// The blur radius.
  final double sigma;

  /// The easing used to move here from the previous keyframe.
  final Curve curve;

  static GlowKeyframe lerp(GlowKeyframe a, GlowKeyframe b, double t) =>
      GlowKeyframe(
        duration: b.duration,
        opacity: lerpDouble(a.opacity, b.opacity, t)!,
        scale: lerpDouble(a.scale, b.scale, t)!,
        sigma: lerpDouble(a.sigma, b.sigma, t)!,
        curve: b.curve,
      );
}
