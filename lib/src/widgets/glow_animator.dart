import 'package:flutter/widgets.dart';

import '../animation/icon_animation.dart';
import '../rendering/glow_painter.dart';
import '../svg/svg_document.dart';

/// Plays a [GlowAnimation] on [document].
class GlowAnimator extends StatefulWidget {
  const GlowAnimator({
    required this.document,
    required this.animation,
    super.key,
  });

  final SvgDocument document;
  final GlowAnimation animation;

  @override
  State<GlowAnimator> createState() => _GlowAnimatorState();
}

class _GlowAnimatorState extends State<GlowAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(GlowAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) _start();
  }

  void _start() {
    final duration = widget.animation.duration;
    _controller.duration = duration;
    if (duration <= Duration.zero) {
      _controller.value = 1;
    } else if (widget.animation.loop) {
      _controller.repeat();
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => CustomPaint(
      painter: GlowPainter(
        document: widget.document,
        animation: widget.animation,
        frame: widget.animation.frameAt(
          widget.animation.duration * _controller.value,
        ),
      ),
    ),
  );
}
