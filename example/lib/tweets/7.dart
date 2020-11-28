import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

/// todo: add link.
class Seven extends Funvas {
  /// Value that the sum of the real and imaginary component needs to surpass
  /// for the complex number to be considered **not** part of the set.
  static const _outsideThreshold = 16;

  /// The maximum number of iterations that we test for the [_outsideThreshold]
  /// for a given complex number.
  static const _maximumIterations = 400;

  static const _realRange = <double>[-2.1, 0.55],
      _imaginaryRange = <double>[-1.2, 1.2];

  @override
  void u(double t) {
    final realRange = [_realRange[0], _realRange[1]],
        imaginaryRange = [_imaginaryRange[0], _imaginaryRange[1]];
    for (var i = 0; i < x.width; i++) {
      for (var j = 0; j < x.height; j++) {
        final real = lerpDouble(realRange[0], realRange[1], i / x.width)!,
            imaginary =
                lerpDouble(imaginaryRange[0], imaginaryRange[1], j / x.height)!;
        var zReal = real, zImaginary = imaginary, n = 0;

        while (n < _maximumIterations) {
          final sReal = zReal * zReal - zImaginary * zImaginary + real;
          zImaginary = 2 * zReal * zImaginary + imaginary;
          zReal = sReal;

          if ((zReal + zImaginary).abs() > _outsideThreshold) {
            break;
          }
          n++;
        }

        c.drawRect(
          Rect.fromCenter(
            center: Offset(i / 1, j / 1),
            width: 1,
            height: 1,
          ),
          Paint()
            ..color = n == _maximumIterations
                ? const Color(0xff000000)
                : HSVColor.fromAHSV(1, 360 * n / _maximumIterations, .9, .6)
                    .toColor(),
        );
      }
    }
  }
}
