import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

/// https://twitter.com/creativemaybeno/status/1333757489670746112?s=20
class Eight extends Funvas {
  // The maximum number of iterations that we test for the threshold for a
  // given complex number.
  static const _iterations = 100;

  @override
  void u(double t) {
    // The center point in the Mandelbrot set about which we rotate to draw
    // corresponding Julia sets.
    const centerPoint = [
      -0.38551857,
      -0.18918556,
    ];
    // The radius which we rotate about the center point in the Mandelbrot set.
    const rotationRadius = 0.35;
    // The duration (in seconds) for completing the rotation about the center
    // point in the Mandelbrot set once.
    const rotationDuration = 5;

    // Value that the sum of the real and imaginary component needs to surpass
    // for the complex number to be considered **not** part of the set.
    // This is arbitrary, so yeah.
    const threshold = 16;
    // The coordinate range I feel you want to see of the set at 0 zoom.
    final reRange = <double>[-1.65, 1.65], imRange = <double>[-1.65, 1.65];

    final c = [
      centerPoint[0] +
          sin(t % rotationDuration / rotationDuration * 2 * pi) *
              rotationRadius,
      centerPoint[1] +
          cos(t % rotationDuration / rotationDuration * 2 * pi) * rotationRadius
    ];

    for (var x = 0; x < this.x.width; x++) {
      for (var y = 0; y < this.x.height; y++) {
        final re = lerpDouble(reRange[0], reRange[1], x / this.x.width)!,
            im = lerpDouble(imRange[0], imRange[1], y / this.x.height)!;

        var n = 0;
        var zre = re, zim = im;
        while (n < _iterations) {
          final tzre = zre * zre - zim * zim + c[0];
          zim = 2 * zre * zim + c[1];
          zre = tzre;

          if (zre.abs() + zim.abs() > threshold) break;
          n++;
        }

        this.c.drawRect(
              Rect.fromLTWH(x / 1, y / 1, 1, 1),
              Paint()
                ..color = n == _iterations
                    ? const Color(0xff000000)
                    : HSVColor.fromAHSV(1, 360 * n / _iterations, .9, .6)
                        .toColor(),
            );
      }
    }
  }
}
