import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

void main() {
  const parser = SvgParser();

  test('each outermost group becomes a single part', () {
    final document = parser.parse('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <path id="a" fill="#ff0000" d="M0,0H10V10H0Z"/>
  <g id="pair" fill="#00ff00" transform="translate(50, 0)">
    <path d="M0,0H10V10H0Z"/>
    <g><path d="M20,20H30V30H20Z"/></g>
  </g>
  <path id="b" fill="#0000ff" d="M90,90H100V100H90Z"/>
</svg>''');

    expect(document.parts.map((p) => p.id), ['a', 'pair', 'b']);
    final pair = document.parts[1];
    expect(pair.color, const Color(0xFF00FF00));
    expect(pair.path.getBounds(), const Rect.fromLTRB(50, 0, 80, 30));
  });

  test('keeps the view box offset', () {
    final document = parser.parse('<svg viewBox="-5 10 20 30"></svg>');
    expect(document.viewBox, const Rect.fromLTWH(-5, 10, 20, 30));
  });

  test('falls back to width and height without a view box', () {
    final document = parser.parse('<svg width="40px" height="20"></svg>');
    expect(document.viewBox, const Rect.fromLTWH(0, 0, 40, 20));
  });

  test('parses short, RGBA and rgb() colours with fill-opacity', () {
    final document = parser.parse('''
<svg viewBox="0 0 1 1">
  <path fill="#f00" d="M0 0h1v1z"/>
  <path fill="#00ff0080" d="M0 0h1v1z"/>
  <path fill="rgb(1, 2, 3)" fill-opacity="0.5" d="M0 0h1v1z"/>
  <path fill="none" d="M0 0h1v1z"/>
</svg>''');

    final colors = document.parts.map((p) => p.color).toList();
    expect(colors[0], const Color(0xFFFF0000));
    expect(colors[1], const Color(0x8000FF00));
    expect(colors[2].a, closeTo(0.5, 0.01));
    expect(colors[2].withValues(alpha: 1), const Color(0xFF010203));
    expect(colors[3].a, 0);
  });
}
