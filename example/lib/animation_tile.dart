import 'package:flutter/material.dart';
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

import 'gallery_page.dart';

/// The sample icon playing [animation], captioned with [label].
class AnimationTile extends StatelessWidget {
  const AnimationTile({
    required this.label,
    required this.animation,
    this.onCompleted,
    this.action,
    super.key,
  });

  final String label;
  final IconAnimation? animation;
  final VoidCallback? onCompleted;

  /// Shown after [label], e.g. a replay button.
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: VectorPulseIcon(
              asset: iconAsset,
              size: 120,
              animation: animation,
              onCompleted: onCompleted,
              semanticLabel: label,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ?action,
            ],
          ),
        ],
      ),
    ),
  );
}
