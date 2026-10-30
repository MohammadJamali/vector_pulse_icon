# vector_pulse_icon

Draw an SVG icon in Flutter and animate its parts: pulse them in turn, glow
behind them, or trace and fill them in.

The package ships no artwork. You bring the SVG, decide how it splits into
parts, and choose an animation.

## Features

- **Pulse:** parts fade out and back in, at random, in index order, or in a
  sequence you choose. A sequence step can be a group of parts that pulse
  together.
- **Glow:** a blurred halo behind each part, moved through keyframes.
- **Draw and fill:** each part's outline is traced, then its fill fades in.
  This plays once and reports when it finishes.
- **Ready-made animations** in `IconAnimations`. Every animation can be
  tuned with plain `const` config objects.
- **Reduced motion:** when the platform asks for reduced motion, the icon is
  drawn still.

## Getting started

```sh
flutter pub add vector_pulse_icon
```

Then declare your SVG as an asset of your app:

```yaml
flutter:
  assets:
    - assets/logo.svg
```

## Usage

```dart
import 'package:vector_pulse_icon/vector_pulse_icon.dart';

// A still icon.
const VectorPulseIcon(asset: 'assets/logo.svg', size: 96);

// A ready-made animation.
const VectorPulseIcon(
  asset: 'assets/logo.svg',
  animation: IconAnimations.loadingPulse,
);
```

Pass `animation: null` to stop animating. Changing to another animation of
the same kind updates it in place, so it doesn't restart.

### Parts

Animations address the icon's parts by index, in document order:

- every top-level `<path>` is one part;
- every outermost `<g>` is one part, with all its paths merged.

So group the shapes you want to animate together. This icon has three parts:

```xml
<svg viewBox="0 0 120 120">
  <g fill="#6C5CE7">   <!-- part 0 -->
    <path d="…"/>
    <path d="…"/>
  </g>
  <g fill="#00B894">   <!-- part 1 -->
    <path d="…"/>
    <path d="…"/>
  </g>
  <path fill="#FDCB6E" d="…"/>   <!-- part 2 -->
</svg>
```

A part has a single colour: the first `fill` set on its first path or on its
group. Give differently coloured shapes their own groups.

### Pulse in a sequence

```dart
VectorPulseIcon(
  asset: 'assets/logo.svg',
  animation: IconAnimations.loadingPulse.copyWith(
    partIndices: [0, 1, 2],
    sequence: [[0, 1], 2], // parts 0 and 1 together, then part 2
  ),
)
```

| `PulseAnimation` field | Meaning |
| --- | --- |
| `partIndices` | The parts that pulse. Empty means all of them. |
| `order` | `PulseOrder.random`, `ascending` or `sequence`. |
| `sequence` | The steps for `PulseOrder.sequence`. Each step is a part index or a list of indices. A list step starts only when all its parts are idle. Parts the sequence leaves out run after it, one at a time. |
| `interval` | The time between starting one pulse and the next. |
| `fadeOutDuration`, `holdDuration`, `fadeInDuration` | The three stages of one pulse. |
| `restOpacity`, `dimOpacity` | The opacity at rest, and the opacity a pulse fades to. |

### Draw and fill once

```dart
VectorPulseIcon(
  asset: 'assets/logo.svg',
  animation: IconAnimations.drawAndFill,
  onCompleted: () => setState(() => introDone = true),
)
```

`DrawFillAnimation` has an optional `draw` and an optional `fill`, each a
`DrawFillPhase`. A phase has a `duration`, a `curve`, and a per-part list of
`delays`.

### Glow

`GlowAnimation` moves through a list of `GlowKeyframe`s. Each keyframe has an
`opacity`, a `scale` and a blur `sigma`. Set `loop` to repeat, and `color` to
use one glow colour instead of each part's own.

### Ready-made animations

| `IconAnimations.` | Kind |
| --- | --- |
| `loadingPulse` | Parts 0 and 1 dim to 30% in turn. |
| `fillEmptyPulse`, `emptyFillPulse` | Slow fades between 30% and full opacity. |
| `pulseGlow` | A short glow, then a slow fade. |
| `musicLightDance` | A rhythmic glow. |
| `drawAndFill` | Traces then fills up to six parts, 100 ms apart. |

The pulse and glow presets use parts `[0, 1]`. Use `copyWith(partIndices: …)`
on a pulse to cover your own icon.

### Loading and errors

`SvgLoader.shared` loads and caches documents. Pass your own `loader` to load
from another `AssetBundle`. If the asset can't be loaded or parsed, the icon
shows nothing, or whatever your `errorBuilder` returns.

## Supported SVG

The parser covers what icon exports usually contain:

- filled `<path>` elements and `<g>` groups (nested groups are merged into
  their outermost group);
- `fill` as `#rgb`, `#rrggbb`, `#rrggbbaa` or `rgb(r, g, b)`, plus
  `fill-opacity`;
- `translate(x, y)` transforms;
- a `viewBox`, or `width` and `height` when there is no `viewBox`.

These are ignored: other shape elements (`<rect>`, `<circle>`, …), strokes,
gradients, and other transforms (`scale`, `rotate`, `matrix`). Convert shapes
to paths and flatten transforms when exporting.

## Example

[`example/`](example) shows every ready-made animation and a grouped sequence
on a sample icon.
