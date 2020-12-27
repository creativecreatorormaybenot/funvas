import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

class _ComplexNumber {
  const _ComplexNumber(this.re, this.im);

  final double re;
  final double im;
}

/// https://twitter.com/creativemaybeno/status/1333395101930942465?s=20
class Seven extends Funvas {
  // The maximum number of iterations that we test for the threshold for a
  // given complex number.
  static const _iterations = 200;

  @override
  void u(double t) {
    const zoomPoint = _ComplexNumber(
        -1.74999841099374081749002483162428393452822172335808534616943930976364725846655540417646727085571962736578151132907961927190726789896685696750162524460775546580822744596887978637416593715319388030232414667046419863755743802804780843375,
        -0.00000000000000165712469295418692325810961981279189026504290127375760405334498110850956047368308707050735960323397389547038231194872482690340369921750514146922400928554011996123112902000856666847088788158433995358406779259404221904755);
    const targetZoomFactor = 42;
    // Duration until the target zoom is reached in seconds.
    const zoomDuration = 5;
    // Value that the sum of the real and imaginary component needs to surpass
    // for the complex number to be considered **not** part of the set.
    // This is arbitrary, so yeah.
    const threshold = 16;
    // The coordinate range I feel you want to see of the set at 0 zoom.
    final reRange = <double>[-2.1, 0.55], imRange = <double>[-1.2, 1.2];

    final noZoomWindow =
            Rect.fromLTRB(reRange[0], imRange[0], reRange[1], imRange[1]),
        targetZoomWindow = Rect.fromCenter(
          center: Offset(zoomPoint.re, zoomPoint.im),
          width: noZoomWindow.width / targetZoomFactor,
          height: noZoomWindow.height / targetZoomFactor,
        );
    final zoomedWindow = Rect.lerp(
        noZoomWindow, targetZoomWindow, t % zoomDuration / zoomDuration)!;

    for (var x = 0; x < this.x.width; x++) {
      for (var y = 0; y < this.x.height; y++) {
        final re = lerpDouble(
                zoomedWindow.left, zoomedWindow.right, x / this.x.width)!,
            im = lerpDouble(
                zoomedWindow.top, zoomedWindow.bottom, y / this.x.height)!;

        var n = 0;
        var zre = re, zim = im;
        while (n < _iterations) {
          final tzre = zre * zre - zim * zim + re;
          zim = 2 * zre * zim + im;
          zre = tzre;

          if (zre.abs() + zim.abs() > threshold) break;
          n++;
        }

        c.drawRect(
          Rect.fromLTWH(x / 1, y / 1, 1, 1),
          Paint()
            ..color = n == _iterations
                ? const Color(0xff000000)
                : HSVColor.fromAHSV(1, 360 * n / _iterations, .9, .6).toColor(),
        );
      }
    }
  }
}
