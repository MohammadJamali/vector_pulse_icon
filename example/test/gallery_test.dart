import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';
import 'package:vector_pulse_icon_example/main.dart';

void main() {
  testWidgets('the gallery plays every animation on the sample icon', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    // Let the asset load, then run the animations for a while.
    await tester.runAsync(() => SvgLoader.shared.load('assets/icon.svg'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(tester.takeException(), isNull);
    expect(find.byType(VectorPulseIcon), findsNWidgets(8));
    expect(find.byTooltip('Replay'), findsOneWidget);

    // The draw-and-fill tile has finished by now and can replay.
    await tester.tap(find.byTooltip('Replay'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
