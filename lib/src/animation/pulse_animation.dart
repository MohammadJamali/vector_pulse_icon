part of 'icon_animation.dart';

/// How a [PulseAnimation] picks the next parts to pulse.
enum PulseOrder {
  /// A random idle part.
  random,

  /// The idle part with the lowest index.
  ascending,

  /// The next step of [PulseAnimation.sequence].
  sequence,
}

/// Repeatedly dims parts of the icon and brings them back: each pulse fades
/// a part from [restOpacity] to [dimOpacity], holds, then fades it back.
class PulseAnimation extends IconAnimation {
  const PulseAnimation({
    this.partIndices = const [],
    this.order = PulseOrder.random,
    this.sequence = const [],
    this.seed,
    this.startDelay = Duration.zero,
    this.interval = const Duration(milliseconds: 100),
    this.fadeOutDuration = const Duration(milliseconds: 160),
    this.fadeOutCurve = Curves.easeOut,
    this.holdDuration = const Duration(milliseconds: 60),
    this.fadeInDuration = const Duration(milliseconds: 650),
    this.fadeInCurve = Curves.easeInOutCubic,
    this.restOpacity = 1,
    this.dimOpacity = 0,
  });

  /// The parts that pulse; empty means all of them.
  final List<int> partIndices;

  final PulseOrder order;

  /// The steps [PulseOrder.sequence] cycles through. A step is a part index,
  /// or a list of part indices that pulse together, e.g. `[0, 1, [2, 3]]`. A
  /// list step starts only once all its parts are idle, so they stay in sync.
  /// Parts the sequence leaves out follow it, one step each.
  final List<Object> sequence;

  /// Seeds [PulseOrder.random]; null picks a different order every run.
  final int? seed;

  final Duration startDelay;

  /// The time between starting one pulse and the next.
  final Duration interval;

  final Duration fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration holdDuration;
  final Duration fadeInDuration;
  final Curve fadeInCurve;

  /// The opacity of a part that is not pulsing.
  final double restOpacity;

  /// The opacity a pulsing part fades to.
  final double dimOpacity;

  Duration get pulseDuration => fadeOutDuration + holdDuration + fadeInDuration;

  /// The opacity of a part [elapsed] into its pulse.
  double opacityAt(Duration elapsed) {
    if (elapsed <= Duration.zero || elapsed >= pulseDuration) {
      return restOpacity;
    }
    if (elapsed < fadeOutDuration) {
      final t = fadeOutCurve.transform(_fraction(elapsed, fadeOutDuration));
      return lerpDouble(restOpacity, dimOpacity, t)!;
    }
    final fadeIn = elapsed - fadeOutDuration - holdDuration;
    if (fadeIn < Duration.zero) return dimOpacity;
    final t = fadeInCurve.transform(_fraction(fadeIn, fadeInDuration));
    return lerpDouble(dimOpacity, restOpacity, t)!;
  }

  PulseAnimation copyWith({
    List<int>? partIndices,
    PulseOrder? order,
    List<Object>? sequence,
    int? seed,
    Duration? startDelay,
    Duration? interval,
    Duration? fadeOutDuration,
    Curve? fadeOutCurve,
    Duration? holdDuration,
    Duration? fadeInDuration,
    Curve? fadeInCurve,
    double? restOpacity,
    double? dimOpacity,
  }) => PulseAnimation(
    partIndices: partIndices ?? this.partIndices,
    order: order ?? this.order,
    sequence: sequence ?? this.sequence,
    seed: seed ?? this.seed,
    startDelay: startDelay ?? this.startDelay,
    interval: interval ?? this.interval,
    fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
    fadeOutCurve: fadeOutCurve ?? this.fadeOutCurve,
    holdDuration: holdDuration ?? this.holdDuration,
    fadeInDuration: fadeInDuration ?? this.fadeInDuration,
    fadeInCurve: fadeInCurve ?? this.fadeInCurve,
    restOpacity: restOpacity ?? this.restOpacity,
    dimOpacity: dimOpacity ?? this.dimOpacity,
  );
}

double _fraction(Duration elapsed, Duration total) => total <= Duration.zero
    ? 1
    : (elapsed.inMicroseconds / total.inMicroseconds).clamp(0.0, 1.0);
