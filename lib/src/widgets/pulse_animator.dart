import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../animation/icon_animation.dart';
import '../rendering/svg_painter.dart';
import '../svg/svg_document.dart';

/// Plays a [PulseAnimation] on [document].
class PulseAnimator extends StatefulWidget {
  const PulseAnimator({
    required this.document,
    required this.animation,
    super.key,
  });

  final SvgDocument document;
  final PulseAnimation animation;

  @override
  State<PulseAnimator> createState() => _PulseAnimatorState();
}

class _PulseAnimatorState extends State<PulseAnimator>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final math.Random _random = math.Random(_animation.seed);

  /// The parts that may pulse, and the [PulseOrder.sequence] steps over them.
  late List<int> _parts;
  late List<List<int>> _steps;

  /// When each pulsing part started its pulse.
  final _pulseStarts = <int, Duration>{};
  var _elapsed = Duration.zero;
  late Duration _nextLaunch;
  var _nextStep = 0;

  PulseAnimation get _animation => widget.animation;

  @override
  void initState() {
    super.initState();
    _configure();
    _nextLaunch = _animation.startDelay;
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didUpdateWidget(PulseAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != _animation ||
        oldWidget.document != widget.document) {
      _configure();
    }
  }

  void _configure() {
    final count = widget.document.parts.length;
    _parts = _animation.partIndices.isEmpty
        ? List.generate(count, (i) => i)
        : {
            for (final i in _animation.partIndices)
              if (i >= 0 && i < count) i,
          }.toList();

    final allowed = _parts.toSet();
    _steps = [
      for (final step in _animation.sequence)
        if (_stepParts(step).where(allowed.contains).toList() case final parts
            when parts.isNotEmpty)
          parts,
    ];
    final listed = _steps.expand((step) => step).toSet();
    _steps.addAll([
      for (final i in _parts)
        if (!listed.contains(i)) [i],
    ]);
    // Keep the place in the sequence when only the config object changed.
    _nextStep = _steps.isEmpty ? 0 : _nextStep % _steps.length;
  }

  List<int> _stepParts(Object step) => switch (step) {
    int index => [index],
    Iterable<int> indices => indices.toSet().toList(),
    _ => throw ArgumentError.value(
      step,
      'sequence',
      'Each step must be an int or a list of ints',
    ),
  };

  void _tick(Duration elapsed) {
    _elapsed = elapsed;
    _pulseStarts.removeWhere(
      (_, start) => elapsed - start >= _animation.pulseDuration,
    );
    if (elapsed >= _nextLaunch) {
      final step = _pickStep();
      if (step != null) {
        for (final i in step) {
          _pulseStarts[i] = elapsed;
        }
        _nextLaunch = elapsed + _animation.interval;
      }
    }
    setState(() {});
  }

  /// The parts to pulse next, or null while none can start.
  List<int>? _pickStep() {
    bool idle(int i) => !_pulseStarts.containsKey(i);
    final idleParts = _parts.where(idle).toList();
    if (idleParts.isEmpty) return null;

    switch (_animation.order) {
      case PulseOrder.random:
        return [idleParts[_random.nextInt(idleParts.length)]];
      case PulseOrder.ascending:
        return [idleParts.reduce(math.min)];
      case PulseOrder.sequence:
        for (var i = 0; i < _steps.length; i++) {
          final index = (_nextStep + i) % _steps.length;
          if (_steps[index].every(idle)) {
            _nextStep = (index + 1) % _steps.length;
            return _steps[index];
          }
        }
        return null;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: SvgPainter(
      document: widget.document,
      opacity: _animation.restOpacity,
      opacities: [
        for (var i = 0; i < widget.document.parts.length; i++)
          switch (_pulseStarts[i]) {
            final start? => _animation.opacityAt(_elapsed - start),
            null => _animation.restOpacity,
          },
      ],
    ),
  );
}
