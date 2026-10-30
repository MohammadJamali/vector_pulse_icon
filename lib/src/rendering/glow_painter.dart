import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../animation/icon_animation.dart';
import '../svg/svg_document.dart';
import 'paint_in_view_box.dart';

/// Paints [document] with a blurred glow, shaped like the part, behind each
/// part in [animation]'s parts.
class GlowPainter extends CustomPainter {
  const GlowPainter({
    required this.document,
    required this.animation,
    required this.frame,
  });

  final SvgDocument document;
  final GlowAnimation animation;
  final GlowKeyframe frame;

  @override
  void paint(Canvas canvas, Size size) {
    final glowing = animation.partIndices;
    paintInViewBox(canvas, size, document.viewBox, () {
      for (var i = 0; i < document.parts.length; i++) {
        final part = document.parts[i];
        if (glowing.isEmpty || glowing.contains(i)) {
          _paintGlow(canvas, part, animation.color ?? part.color);
        }
        canvas.drawPath(part.path, Paint()..color = part.color);
      }
    });
  }

  void _paintGlow(Canvas canvas, SvgPart part, Color color) {
    final bounds = part.path.getBounds();
    final center = bounds.center;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(frame.scale)
      ..translate(-center.dx, -center.dy)
      ..saveLayer(
        bounds.inflate(frame.sigma * 8),
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: frame.sigma,
            sigmaY: frame.sigma,
            tileMode: ui.TileMode.decal,
          )
          ..colorFilter = ColorFilter.mode(
            color.withValues(alpha: frame.opacity),
            BlendMode.srcIn,
          ),
      )
      ..drawPath(part.path, Paint()..color = const Color(0xFFFFFFFF))
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(GlowPainter oldDelegate) =>
      oldDelegate.document != document ||
      oldDelegate.animation != animation ||
      oldDelegate.frame.opacity != frame.opacity ||
      oldDelegate.frame.scale != frame.scale ||
      oldDelegate.frame.sigma != frame.sigma;
}
