import 'package:flutter/material.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

import 'animation_tile.dart';

/// Plays [IconAnimations.drawAndFill] once, then offers to replay it.
class DrawFillTile extends StatefulWidget {
  const DrawFillTile({super.key});

  @override
  State<DrawFillTile> createState() => _DrawFillTileState();
}

class _DrawFillTileState extends State<DrawFillTile> {
  var _run = 0;
  var _done = false;

  @override
  Widget build(BuildContext context) => AnimationTile(
    // A new key restarts the one-shot animation.
    key: ValueKey(_run),
    label: 'drawAndFill',
    animation: IconAnimations.drawAndFill,
    onCompleted: () => setState(() => _done = true),
    action: IconButton(
      tooltip: 'Replay',
      icon: const Icon(Icons.replay_rounded),
      onPressed: _done
          ? () => setState(() {
              _run++;
              _done = false;
            })
          : null,
    ),
  );
}
