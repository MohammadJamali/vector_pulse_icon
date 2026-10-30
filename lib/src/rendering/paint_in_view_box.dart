import 'dart:math' as math;
import 'dart:ui';

/// Runs [paint] with [canvas] mapped so [viewBox] is scaled to fit [size] and
/// centred in it, as SVG's default `xMidYMid meet` does.
void paintInViewBox(
  Canvas canvas,
  Size size,
  Rect viewBox,
  void Function() paint,
) {
  if (viewBox.isEmpty || size.isEmpty) return;
  final scale = math.min(
    size.width / viewBox.width,
    size.height / viewBox.height,
  );
  canvas
    ..save()
    ..translate(
      (size.width - viewBox.width * scale) / 2,
      (size.height - viewBox.height * scale) / 2,
    )
    ..scale(scale)
    ..translate(-viewBox.left, -viewBox.top);
  paint();
  canvas.restore();
}
