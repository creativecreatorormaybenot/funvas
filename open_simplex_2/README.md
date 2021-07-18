# open_simplex_2 [![Pub version](https://img.shields.io/pub/v/open_simplex_2.svg)](https://pub.dev/packages/open_simplex_2) [![GitHub stars](https://img.shields.io/github/stars/creativecreatorormaybenot/funvas.svg)](https://github.com/creativecreatorormaybenot/funvas) [![Twitter Follow](https://img.shields.io/twitter/follow/creativemaybeno?label=Follow&style=social)](https://twitter.com/creativemaybeno)

Dart implementation of [KdotJPG's OpenSimplex2](https://github.com/KdotJPG/OpenSimplex2) noise
algorithms.

## Getting started

To use this plugin, follow the [installing guide](https://pub.dev/packages/open_simplex_2/install).

## Usage

The package currently offers two OpenSimplex 2 noise implementations:

* [`OpenSimplex2F`](https://pub.dev/documentation/open_simplex_2/latest/open_simplex_2/OpenSimplex2F-class.html),
  which is the *faster* version of OpenSimplex 2.
* [`OpenSimplex2S`](https://pub.dev/documentation/open_simplex_2/latest/open_simplex_2/OpenSimplex2S-class.html),
  which is the *smoother* version of OpenSimplex 2.

Both of them are used in the same way. You initialize an instance with a seed:

```dart
final noise = OpenSimplex2F(42);
```

This instance now allows you to evaluate noise. Here are some example calls:

```dart
noise.noise2(x, y);
noise.noise3Classic(x, y, z);
noise.noise3XYBeforeZ(x, y, z);
noise.noise4Classic(x, y, z);
noise.noise4XYBeforeZW(x, y, z);
```

### Common interface

Both `OpenSimplex2F` and `OpenSimplex2S` share the same public interface.
This is defined as [`OpenSimplex2`](https://pub.dev/documentation/open_simplex_2/latest/open_simplex_2/OpenSimplex2-class.html).

This is useful e.g. when you want to toggle between the smoother and faster variant:

```dart
late OpenSimplex2 noise;

void initNoise({required bool faster}) {
  if (faster) {
    noise = OpenSimplex2F(42);
  } else {
    noise = OpenSimplex2S(42);
  }
}
```

## Motivation

I ported the library to Dart in order to use it in my [funvas animations](https://github.com/creativecreatorormaybenot/funvas).

If you are interested, you can view [the gallery](https://funvas.creativemaybeno.dev), follow
[on Twitter](https://twitter.com/creativemaybeno) (where I regularly post animations), or view some
of the example integrations I wrote :)

Here are two examples to start:

* [funvas animation no. 33](https://github.com/creativecreatorormaybenot/funvas/blob/main/funvas_tweets/lib/src/33.dart)
* [open_simplex_2 example app](https://github.com/creativecreatorormaybenot/funvas/blob/main/open_simplex_2/example/lib/main.dart)

## Background

To understand how the noise in OpenSimplex 2 works, see [KdotJPG's Reddit post](https://www.reddit.com/r/VoxelGameDev/comments/ee94wg/supersimplex_the_better_opensimplex_new_gradient/?utm_source=share&utm_medium=web2x&context=3).

### Implementation

The current implementation is based on the [Java implementation in `KdotJPG/OpenSimplex2`](https://github.com/KdotJPG/OpenSimplex2/tree/a186b9bb644747c936d7cba748d11f28b1cee66e/java).

I see two potential ways to improve on it:

* Port the `areagen` code from the main repo.
* Use the newer, [faster implementations](https://github.com/Auburn/FastNoiseLite/blob/349a518064003b74170037d867da8e3a68e1b74e/Java/FastNoiseLite.java)
  by K.jpg that have not yet been merged into the main repo.
