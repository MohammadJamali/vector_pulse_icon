import 'dart:ui';

/// A parsed SVG, reduced to the filled shapes the animations work with.
class SvgDocument {
  const SvgDocument({required this.viewBox, required this.parts});

  /// The area of user space the drawing occupies.
  final Rect viewBox;

  /// The animatable shapes, in paint order. Animations address them by index.
  final List<SvgPart> parts;
}

/// One animatable shape: a top-level `<path>`, or a whole `<g>` merged into a
/// single path.
class SvgPart {
  const SvgPart({required this.id, required this.path, required this.color});

  final String id;
  final Path path;

  /// The fill colour, including its opacity.
  final Color color;
}
