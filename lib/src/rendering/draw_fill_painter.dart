import 'package:flutter/rendering.dart';

import '../animation/icon_animation.dart';
import '../svg/svg_document.dart';
import 'paint_in_view_box.dart';

/// Paints [document] as it looks [elapsed] into [animation].
class DrawFillPainter extends CustomPainter {
  const DrawFillPainter({
    required this.document,
    required this.animation,
    required this.elapsed,
  });

  final SvgDocument document;
  final DrawFillAnimation animation;
  final Duration elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    final time = elapsed - animation.startDelay;
    final draw = animation.draw;
    final fill = animation.fill;
    paintInViewBox(canvas, size, document.viewBox, () {
      for (var i = 0; i < document.parts.length; i++) {
        final part = document.parts[i];

        final filled = fill?.progressAt(i, time) ?? 0;
        if (filled > 0) {
          canvas.drawPath(
            part.path,
            Paint()
              ..color = part.color.withValues(alpha: part.color.a * filled),
          );
        }

        final drawn = draw?.progressAt(i, time) ?? 0;
        if (drawn > 0) {
          canvas.drawPath(
            _trim(part.path, drawn),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = animation.strokeWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = animation.strokeColor ?? part.color,
          );
        }
      }
    });
  }

  /// The first [fraction] of each contour of [path].
  Path _trim(Path path, double fraction) {
    if (fraction >= 1) return path;
    final trimmed = Path();
    for (final metric in path.computeMetrics()) {
      trimmed.addPath(
        metric.extractPath(0, metric.length * fraction),
        Offset.zero,
      );
    }
    return trimmed;
  }

  @override
  bool shouldRepaint(DrawFillPainter oldDelegate) =>
      oldDelegate.document != document ||
      oldDelegate.animation != animation ||
      oldDelegate.elapsed != elapsed;
}
