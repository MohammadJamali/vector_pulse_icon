import 'package:flutter/widgets.dart';

import '../animation/icon_animation.dart';
import '../rendering/svg_painter.dart';
import '../svg/svg_document.dart';
import '../svg/svg_loader.dart';
import 'draw_fill_animator.dart';
import 'glow_animator.dart';
import 'pulse_animator.dart';

/// Draws the SVG [asset], optionally playing an [IconAnimation] on it.
///
/// With reduced motion requested the icon is drawn still.
class VectorPulseIcon extends StatefulWidget {
  const VectorPulseIcon({
    required this.asset,
    this.size = 64,
    this.animation,
    this.onCompleted,
    this.semanticLabel,
    this.errorBuilder,
    this.loader,
    super.key,
  });

  /// The SVG's asset key, as declared in the app's `pubspec.yaml`; for an
  /// asset of another package use `packages/<package>/<path>`.
  final String asset;

  final double size;

  /// The animation to play; null draws the icon still. Changing it to one of
  /// the same kind updates it in place, so it does not restart.
  final IconAnimation? animation;

  /// Called when a one-shot animation ([DrawFillAnimation]) finishes; looping
  /// animations never finish.
  final VoidCallback? onCompleted;

  final String? semanticLabel;

  /// Builds what to show when [asset] cannot be loaded or parsed; defaults
  /// to nothing.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Defaults to [SvgLoader.shared].
  final SvgLoader? loader;

  @override
  State<VectorPulseIcon> createState() => _VectorPulseIconState();
}

class _VectorPulseIconState extends State<VectorPulseIcon> {
  late Future<SvgDocument> _document = _load();

  Future<SvgDocument> _load() =>
      (widget.loader ?? SvgLoader.shared).load(widget.asset);

  @override
  void didUpdateWidget(VectorPulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset || oldWidget.loader != widget.loader) {
      _document = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final animation = (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? null
        : widget.animation;
    final icon = SizedBox.square(
      dimension: widget.size,
      child: KeyedSubtree(
        key: ValueKey(animation == null ? 'pulse-icon' : 'pulse-icon-animated'),
        child: FutureBuilder(
          future: _document,
          builder: (context, snapshot) {
            if (snapshot.error case final error?) {
              return widget.errorBuilder?.call(context, error) ??
                  const SizedBox.shrink();
            }
            final document = snapshot.data;
            if (document == null) return const SizedBox.shrink();
            return switch (animation) {
              null => CustomPaint(painter: SvgPainter(document: document)),
              PulseAnimation() => PulseAnimator(
                document: document,
                animation: animation,
              ),
              GlowAnimation() => GlowAnimator(
                document: document,
                animation: animation,
              ),
              DrawFillAnimation() => DrawFillAnimator(
                document: document,
                animation: animation,
                onCompleted: widget.onCompleted,
              ),
            };
          },
        ),
      ),
    );
    final label = widget.semanticLabel;
    return label == null
        ? ExcludeSemantics(child: icon)
        : Semantics(image: true, label: label, child: icon);
  }
}
