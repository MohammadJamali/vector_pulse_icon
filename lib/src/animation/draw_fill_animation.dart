part of 'icon_animation.dart';

/// Plays once: traces each part's outline, then fades its fill in.
class DrawFillAnimation extends IconAnimation {
  const DrawFillAnimation({
    this.draw,
    this.fill,
    this.startDelay = Duration.zero,
    this.strokeWidth = 1,
    this.strokeColor,
  });

  /// Timing of the outline tracing; null skips it.
  final DrawFillPhase? draw;

  /// Timing of the fill fading in; null skips it.
  final DrawFillPhase? fill;

  final Duration startDelay;

  final double strokeWidth;

  /// The outline colour; null uses each part's own colour.
  final Color? strokeColor;

  /// The time until every part of a [partCount]-part icon is drawn and filled.
  Duration duration(int partCount) {
    var end = Duration.zero;
    for (final phase in [draw, fill].nonNulls) {
      for (var i = 0; i < partCount; i++) {
        final partEnd = phase.delayOf(i) + phase.duration;
        if (partEnd > end) end = partEnd;
      }
    }
    return startDelay + end;
  }
}

/// The timing of one phase of a [DrawFillAnimation], per part.
class DrawFillPhase {
  const DrawFillPhase({
    this.duration = const Duration(milliseconds: 800),
    this.delays = const [],
    this.curve = Curves.ease,
  });

  /// How long the phase takes for each part.
  final Duration duration;

  /// When each part starts, by part index; missing parts start immediately.
  final List<Duration> delays;

  final Curve curve;

  Duration delayOf(int partIndex) =>
      partIndex < delays.length ? delays[partIndex] : Duration.zero;

  /// How far part [partIndex] is through this phase, eased, [elapsed] after
  /// the animation's start delay.
  double progressAt(int partIndex, Duration elapsed) =>
      curve.transform(_fraction(elapsed - delayOf(partIndex), duration));
}
