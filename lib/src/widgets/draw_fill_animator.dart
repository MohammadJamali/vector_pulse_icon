import 'package:flutter/widgets.dart';

import '../animation/icon_animation.dart';
import '../rendering/draw_fill_painter.dart';
import '../svg/svg_document.dart';

/// Plays a [DrawFillAnimation] on [document] once, then calls [onCompleted].
class DrawFillAnimator extends StatefulWidget {
  const DrawFillAnimator({
    required this.document,
    required this.animation,
    this.onCompleted,
    super.key,
  });

  final SvgDocument document;
  final DrawFillAnimation animation;
  final VoidCallback? onCompleted;

  @override
  State<DrawFillAnimator> createState() => _DrawFillAnimatorState();
}

class _DrawFillAnimatorState extends State<DrawFillAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onCompleted?.call();
      })
      ..forward();
  }

  Duration get _duration =>
      widget.animation.duration(widget.document.parts.length);

  @override
  void didUpdateWidget(DrawFillAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _duration;
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
      painter: DrawFillPainter(
        document: widget.document,
        animation: widget.animation,
        elapsed: _duration * _controller.value,
      ),
    ),
  );
}
