import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../svg/svg_document.dart';
import 'paint_in_view_box.dart';

/// Paints every part of [document] in its own colour, scaled by
/// [opacities], by part index; parts past its end are drawn at [opacity].
class SvgPainter extends CustomPainter {
  const SvgPainter({
    required this.document,
    this.opacities = const [],
    this.opacity = 1,
  });

  final SvgDocument document;
  final List<double> opacities;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    paintInViewBox(canvas, size, document.viewBox, () {
      final parts = document.parts;
      for (var i = 0; i < parts.length; i++) {
        final color = parts[i].color;
        final alpha = color.a * (i < opacities.length ? opacities[i] : opacity);
        if (alpha <= 0) continue;
        canvas.drawPath(
          parts[i].path,
          Paint()..color = color.withValues(alpha: alpha),
        );
      }
    });
  }

  @override
  bool shouldRepaint(SvgPainter oldDelegate) =>
      oldDelegate.document != document ||
      oldDelegate.opacity != opacity ||
      !listEquals(oldDelegate.opacities, opacities);
}
