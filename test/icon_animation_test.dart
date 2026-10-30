import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

void main() {
  group('PulseAnimation.opacityAt', () {
    const pulse = PulseAnimation(
      fadeOutDuration: Duration(milliseconds: 100),
      fadeOutCurve: Curves.linear,
      holdDuration: Duration(milliseconds: 100),
      fadeInDuration: Duration(milliseconds: 100),
      fadeInCurve: Curves.linear,
      restOpacity: 1,
      dimOpacity: 0.2,
    );

    test('fades out, holds, then fades back in', () {
      double at(int ms) => pulse.opacityAt(Duration(milliseconds: ms));
      expect(at(0), 1);
      expect(at(50), closeTo(0.6, 1e-9));
      expect(at(150), 0.2);
      expect(at(250), closeTo(0.6, 1e-9));
      expect(at(300), 1);
    });
  });

  test('DrawFillAnimation.duration covers the latest part of either phase', () {
    const animation = DrawFillAnimation(
      startDelay: Duration(milliseconds: 50),
      draw: DrawFillPhase(
        duration: Duration(milliseconds: 100),
        delays: [Duration.zero, Duration(milliseconds: 400)],
      ),
      fill: DrawFillPhase(
        duration: Duration(milliseconds: 200),
        delays: [Duration(milliseconds: 100)],
      ),
    );
    expect(animation.duration(2), const Duration(milliseconds: 550));
    expect(animation.duration(1), const Duration(milliseconds: 350));
  });

  test('GlowAnimation.frameAt interpolates between keyframes', () {
    const glow = GlowAnimation(
      keyframes: [
        GlowKeyframe(duration: Duration.zero, opacity: 0, scale: 1, sigma: 0),
        GlowKeyframe(
          duration: Duration(milliseconds: 100),
          opacity: 1,
          scale: 2,
          sigma: 10,
        ),
      ],
    );
    final frame = glow.frameAt(const Duration(milliseconds: 50));
    expect(frame.opacity, 0.5);
    expect(frame.scale, 1.5);
    expect(frame.sigma, 5);
    expect(glow.frameAt(const Duration(seconds: 1)).opacity, 1);
  });
}
