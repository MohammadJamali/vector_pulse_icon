import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

import 'svg_document.dart';

/// Parses the subset of SVG the icon uses: filled `<path>`s, optionally
/// grouped with `<g>` and positioned with `translate(...)`.
///
/// Every top-level `<path>` becomes one [SvgPart], and so does every
/// outermost `<g>`, whose paths are merged. The parts of
/// `<path/><g><path/><path/></g><path/>` are therefore `[0, 1, 2]`.
class SvgParser {
  const SvgParser();

  SvgDocument parse(String source) {
    final root = XmlDocument.parse(source).rootElement;
    final parts = <SvgPart>[];
    for (final element in _partElements(root)) {
      final part = element.localName == 'g'
          ? _groupPart(element, parts.length)
          : _pathPart(element, parts.length);
      if (part != null) parts.add(part);
    }
    return SvgDocument(viewBox: _viewBox(root), parts: parts);
  }

  /// Every `<path>` outside a group and every outermost `<g>`, in document
  /// order.
  Iterable<XmlElement> _partElements(XmlElement parent) sync* {
    for (final element in parent.childElements) {
      switch (element.localName) {
        case 'path' || 'g':
          yield element;
        case 'defs' || 'namedview':
          break;
        default:
          yield* _partElements(element);
      }
    }
  }

  SvgPart? _pathPart(XmlElement element, int index) {
    final path = _path(element);
    if (path == null) return null;
    return SvgPart(
      id: element.getAttribute('id') ?? 'path_$index',
      path: path,
      color: _fill([element]),
    );
  }

  /// Merges every path inside [group], nested groups included. A part has a
  /// single colour, so it takes the first fill set on the first path or on
  /// the group; give differently coloured shapes their own group.
  SvgPart? _groupPart(XmlElement group, int index) {
    final merged = Path();
    XmlElement? first;
    for (final element in group.findAllElements('path')) {
      final source = _path(element);
      if (source == null) continue;
      var path = source;
      first ??= element;
      for (
        var parent = element.parentElement;
        parent != null && parent != group.parentElement;
        parent = parent.parentElement
      ) {
        path = _translate(path, parent.getAttribute('transform'));
      }
      merged.addPath(path, Offset.zero);
    }
    if (first == null) return null;
    return SvgPart(
      id: group.getAttribute('id') ?? 'group_$index',
      path: merged,
      color: _fill([first, group]),
    );
  }

  Path? _path(XmlElement element) {
    final data = element.getAttribute('d');
    if (data == null || data.trim().isEmpty) return null;
    return _translate(
      parseSvgPathData(data),
      element.getAttribute('transform'),
    );
  }

  /// The fill of the first element in [elements] that sets one, with its
  /// `fill-opacity`. Missing fills are transparent.
  Color _fill(List<XmlElement> elements) {
    String? attribute(String name) => elements
        .map((element) => element.getAttribute(name))
        .nonNulls
        .firstOrNull;

    final color = _color(attribute('fill')) ?? const Color(0x00000000);
    final opacity = _number(attribute('fill-opacity'));
    return opacity == null
        ? color
        : color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0));
  }

  Rect _viewBox(XmlElement root) {
    final values = (root.getAttribute('viewBox') ?? '')
        .split(RegExp(r'[\s,]+'))
        .where((value) => value.isNotEmpty)
        .map(double.tryParse)
        .toList();
    if (values.length == 4 && values.every((value) => value != null)) {
      return Rect.fromLTWH(values[0]!, values[1]!, values[2]!, values[3]!);
    }
    return Rect.fromLTWH(
      0,
      0,
      _number(root.getAttribute('width')) ?? 0,
      _number(root.getAttribute('height')) ?? 0,
    );
  }

  /// Applies a `translate(x[, y])` transform; any other transform is ignored.
  Path _translate(Path path, String? transform) {
    if (transform == null) return path;
    final match = RegExp(
      r'translate\(\s*([-+\d.eE]+)(?:[\s,]+([-+\d.eE]+))?\s*\)',
    ).firstMatch(transform);
    if (match == null) return path;
    return path.shift(
      Offset(
        double.tryParse(match.group(1)!) ?? 0,
        double.tryParse(match.group(2) ?? '0') ?? 0,
      ),
    );
  }

  double? _number(String? value) =>
      value == null ? null : double.tryParse(value.trim().replaceAll('px', ''));

  /// Parses `#rgb`, `#rrggbb`, `#rrggbbaa` and `rgb(r, g, b)`.
  Color? _color(String? value) {
    final color = value?.trim().toLowerCase() ?? '';
    if (color.startsWith('#')) {
      var hex = color.substring(1);
      if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
      if (hex.length == 6) hex = '${hex}ff';
      final rgba = hex.length == 8 ? int.tryParse(hex, radix: 16) : null;
      if (rgba == null) return null;
      return Color((rgba & 0xFF) << 24 | rgba >> 8);
    }
    final rgb = RegExp(
      r'^rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$',
    ).firstMatch(color);
    if (rgb == null) return null;
    final [r, g, b] = [for (var i = 1; i <= 3; i++) int.parse(rgb.group(i)!)];
    return Color.fromARGB(255, r, g, b);
  }
}
