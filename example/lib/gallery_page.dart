import 'package:flutter/material.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

import 'animation_tile.dart';
import 'draw_fill_tile.dart';

/// The sample icon. Its parts are 0: the top and bottom petals (one group),
/// 1: the left and right petals (another group), 2: the centre dot.
const iconAsset = 'assets/icon.svg';

/// Every part pulsing in turn, the two petal groups together first.
const _groupedSequence = PulseAnimation(
  order: PulseOrder.sequence,
  sequence: [
    [0, 1],
    2,
  ],
  interval: Duration(milliseconds: 450),
  fadeOutDuration: Duration(milliseconds: 250),
  holdDuration: Duration(milliseconds: 150),
  fadeInDuration: Duration(milliseconds: 400),
  dimOpacity: 0.2,
);

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('vector_pulse_icon')),
    body: GridView.extent(
      maxCrossAxisExtent: 220,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: const [
        AnimationTile(label: 'Still', animation: null),
        AnimationTile(
          label: 'loadingPulse',
          animation: IconAnimations.loadingPulse,
        ),
        AnimationTile(
          label: 'fillEmptyPulse',
          animation: IconAnimations.fillEmptyPulse,
        ),
        AnimationTile(
          label: 'emptyFillPulse',
          animation: IconAnimations.emptyFillPulse,
        ),
        AnimationTile(label: 'pulseGlow', animation: IconAnimations.pulseGlow),
        AnimationTile(
          label: 'musicLightDance',
          animation: IconAnimations.musicLightDance,
        ),
        AnimationTile(label: 'Grouped sequence', animation: _groupedSequence),
        DrawFillTile(),
      ],
    ),
  );
}
