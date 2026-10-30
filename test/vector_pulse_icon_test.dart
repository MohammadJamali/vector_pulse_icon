import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_pulse_icon/src/rendering/svg_painter.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

class _FakeBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(_svg.codeUnits));

  static const _svg = '''
<svg viewBox="0 0 30 10">
  <path fill="#ff0000" d="M0 0h10v10H0z"/>
  <path fill="#00ff00" d="M10 0h10v10H10z"/>
  <path fill="#0000ff" d="M20 0h10v10H20z"/>
</svg>''';
}

void main() {
  testWidgets('a grouped sequence step pulses its parts together', (
    tester,
  ) async {
    const pulse = PulseAnimation(
      order: PulseOrder.sequence,
      sequence: [
        [0, 1],
        2,
      ],
      interval: Duration(milliseconds: 100),
      fadeOutDuration: Duration(milliseconds: 100),
      holdDuration: Duration(milliseconds: 100),
      fadeInDuration: Duration(milliseconds: 100),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: VectorPulseIcon(
          asset: 'icon.svg',
          animation: pulse,
          loader: SvgLoader(bundle: _FakeBundle()),
        ),
      ),
    );
    // Load the SVG, then start the pulse ticker.
    await tester.pump();
    await tester.pump();

    List<double> opacities() {
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(VectorPulseIcon),
          matching: find.byType(CustomPaint),
        ),
      );
      return (paint.painter! as SvgPainter).opacities;
    }

    // The first step has started: parts 0 and 1 dim together, 2 rests.
    await tester.pump(const Duration(milliseconds: 150));
    expect(opacities(), [0, 0, 1]);

    // Then part 2 follows on its own.
    await tester.pump(const Duration(milliseconds: 100));
    expect(opacities()[2], lessThan(1));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows the error builder when the asset cannot load', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: VectorPulseIcon(
          asset: 'missing.svg',
          loader: SvgLoader(bundle: _MissingBundle()),
          errorBuilder: (context, error) => const Text('no icon'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('no icon'), findsOneWidget);
  });
}

class _MissingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future.error(FlutterError('Unable to load asset: $key'));
}
